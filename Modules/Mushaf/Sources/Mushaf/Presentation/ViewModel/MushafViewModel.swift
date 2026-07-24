//
//  MushafViewModel.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

//
//  MushafViewModel.swift
//  Mushaf
//

import Foundation
import Bookmarks
import Common
@MainActor
final class MushafViewModel: ObservableObject {
    @Published private(set) var pages: [Int: MushafPage] = [:]
    @Published var pageNumber: Int = 1 {
        didSet {
            refreshCurrentPageBookmarkState()
            if let page = pages[pageNumber] {
                saveReadingProgress(for: page)
            }
        }
    }
    private static let tajweedKey = "com.almahir.isTajweedEnabled"

    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var isTajweedEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isTajweedEnabled, forKey: Self.tajweedKey)
        }
    }

    // MARK: - Bookmarks

    struct AyahKey: Hashable {
        let surah: Int
        let ayah: Int
    }

    @Published private(set) var isCurrentPageBookmarked = false
    @Published private(set) var bookmarkedSurahNumbers: Set<Int> = []
    @Published private(set) var bookmarkedAyahKeys: Set<AyahKey> = []

    let totalPages = 604
    private let getPage: GetMushafPageUseCase
    private let pageBookmarkUseCase: PageBookmarkUseCase
    private let surahBookmarkUseCase: SurahBookmarkUseCase
    private let ayahBookmarkUseCase: AyahBookmarkUseCase
    private var loadingTasks: [Int: Task<Void, Never>] = [:]

    init(
        getPage: GetMushafPageUseCase,
        startPage: Int = 1,
        pageBookmarkUseCase: PageBookmarkUseCase,
        surahBookmarkUseCase: SurahBookmarkUseCase,
        ayahBookmarkUseCase: AyahBookmarkUseCase
    ) {
        if UserDefaults.standard.object(forKey: Self.tajweedKey) == nil {
            self.isTajweedEnabled = true
        } else {
            self.isTajweedEnabled = UserDefaults.standard.bool(forKey: Self.tajweedKey)
        }
        self.getPage = getPage
        self.pageBookmarkUseCase = pageBookmarkUseCase
        self.surahBookmarkUseCase = surahBookmarkUseCase
        self.ayahBookmarkUseCase = ayahBookmarkUseCase
        self.pageNumber = startPage
        self.loadPageIfNeeded(startPage)
        self.loadBookmarkIndex()
    }

    var currentPage: MushafPage? {
        pages[pageNumber]
    }

    func loadPage(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        pageNumber = number
        loadPageIfNeeded(number)
        loadPageIfNeeded(min(number + 1, totalPages))
        loadPageIfNeeded(max(number - 1, 1))
    }

    func loadPageIfNeeded(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        guard pages[number] == nil, loadingTasks[number] == nil else { return }
        if number == pageNumber {
            isLoading = true
            errorMessage = nil
        }
        loadingTasks[number] = Task {
            defer { loadingTasks[number] = nil }
            do {
                await Task.yield()
                let loadedPage = try getPage.execute(pageNumber: number)
                if !Task.isCancelled {
                    pages[number] = loadedPage
                    if number == pageNumber {
                        isLoading = false
                        saveReadingProgress(for: loadedPage)
                    }
                }
            } catch {
                if !Task.isCancelled, number == pageNumber {
                    errorMessage = "Failed to load page \(number): \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    private func saveReadingProgress(for page: MushafPage) {
        if let progress = page.toReadingProgress() {
            ReadingProgressStore.shared.save(progress)
        }
    }

    public func reloadSettings() {
        if UserDefaults.standard.object(forKey: Self.tajweedKey) == nil {
            self.isTajweedEnabled = true
        } else {
            self.isTajweedEnabled = UserDefaults.standard.bool(forKey: Self.tajweedKey)
        }
    }

    func nextPage() { loadPage(pageNumber + 1) }
    func previousPage() { loadPage(pageNumber - 1) }

    // MARK: - Bookmark state

    /// Loaded once at startup and kept in sync in-memory on every toggle,
    /// rather than re-querying SwiftData on every page turn.
    private func loadBookmarkIndex() {
        do {
            bookmarkedSurahNumbers = Set(try surahBookmarkUseCase.fetchAll().map(\.surahNumber))
            bookmarkedAyahKeys = Set(
                try ayahBookmarkUseCase.fetchAll().map { AyahKey(surah: $0.surahNumber, ayah: $0.ayahNumber) }
            )
        } catch {
            errorMessage = "Couldn't load bookmarks: \(error.localizedDescription)"
        }
        refreshCurrentPageBookmarkState()
    }

    /// Cheap point-lookup, safe to call on every page change.
    private func refreshCurrentPageBookmarkState() {
        isCurrentPageBookmarked = (try? pageBookmarkUseCase.isBookmarked(pageNumber: pageNumber)) ?? false
    }

    func isAyahBookmarked(surah: Int, ayah: Int) -> Bool {
        bookmarkedAyahKeys.contains(AyahKey(surah: surah, ayah: ayah))
    }

    func isSurahBookmarked(_ surahNumber: Int) -> Bool {
        bookmarkedSurahNumbers.contains(surahNumber)
    }

    // MARK: - Bookmark toggles
    func toggleBookmarkForCurrentPage() {
        guard let page = pages[pageNumber] else { return }
        do {
            if isCurrentPageBookmarked {
                try pageBookmarkUseCase.remove(pageNumber: pageNumber)
            } else {
                try pageBookmarkUseCase.add(
                    pageNumber: pageNumber,
                    surahName: primarySurahName(for: page),
                    juzNumber: JuzPageMap.juzNumber(forPage: pageNumber)
                )
            }
            isCurrentPageBookmarked.toggle()
            NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
        } catch {
            errorMessage = "Couldn't update bookmark: \(error.localizedDescription)"
        }
    }

    /// A page's surah banner (if any) tells you which surah opens on this
    /// page. If the page has no banner line — it's mid-surah — fall back to
    /// whichever surah the first ayah word on the page belongs to.
    private func primarySurahName(for page: MushafPage) -> String {
        if let bannerSurah = page.lines.first(where: { $0.lineType == .surahName })?.surahNumber {
            return SurahNames.name(for: bannerSurah)
        }
        if let surah = page.lines.flatMap(\.words).first?.surah {
            return SurahNames.name(for: surah)
        }
        return ""
    }
    func toggleBookmarkForSurah(surahNumber: Int) {
        do {
            if bookmarkedSurahNumbers.contains(surahNumber) {
                try surahBookmarkUseCase.remove(surahNumber: surahNumber)
                bookmarkedSurahNumbers.remove(surahNumber)
            } else {
                guard let info = SurahBookmarkMetadata.info(for: surahNumber) else { return }
                try surahBookmarkUseCase.add(
                    surahNumber: surahNumber,
                    arabicName: SurahNames.name(for: surahNumber),
                    englishName: info.englishName,
                    ayahCount: info.ayahCount,
                    pageNumber: pageNumber // this page IS the surah's start page —
                                           // that's where its banner line renders
                )
                bookmarkedSurahNumbers.insert(surahNumber)
            }
            NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
        } catch {
            errorMessage = "Couldn't update bookmark: \(error.localizedDescription)"
        }
    }

    func toggleBookmarkForAyah(surahNumber: Int, ayahNumber: Int, arabicText: String, surahName: String) {
        let key = AyahKey(surah: surahNumber, ayah: ayahNumber)
        do {
            if bookmarkedAyahKeys.contains(key) {
                try ayahBookmarkUseCase.remove(surahNumber: surahNumber, ayahNumber: ayahNumber)
                bookmarkedAyahKeys.remove(key)
            } else {
                try ayahBookmarkUseCase.add(
                    surahNumber: surahNumber,
                    ayahNumber: ayahNumber,
                    arabicText: arabicText,
                    translation: "", // ⚠️ see "Two integration gaps" below
                    surahName: surahName,
                    pageNumber: pageNumber
                )
                bookmarkedAyahKeys.insert(key)
            }
            NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
        } catch {
            errorMessage = "Couldn't update bookmark: \(error.localizedDescription)"
        }
    }
    private func juzNumber(for page: Int) -> Int {
        JuzPageMap.juzNumber(forPage: page)
    }
}

