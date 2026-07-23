//
//  BookmarksViewModel.swift
//  Bookmarks (Presentation)
//

import Foundation

@MainActor
final class BookmarksViewModel: ObservableObject {
    @Published var selectedTab: BookmarkTab = .surah
    @Published var searchText: String = ""

    @Published private(set) var surahBookmarks: [SurahBookmark] = []
    @Published private(set) var ayahBookmarks: [AyahBookmark] = []
    @Published private(set) var pageBookmarks: [PageBookmark] = []
    @Published private(set) var sheikhBookmarks: [SheikhBookmark] = []

    @Published var errorMessage: String?

    // Depends only on Domain use-case protocols — never on a repository,
    // a DAO, or a SwiftData entity.
    private let surahBookmarkUseCase: SurahBookmarkUseCase
    private let ayahBookmarkUseCase: AyahBookmarkUseCase
    private let pageBookmarkUseCase: PageBookmarkUseCase
    private let sheikhBookmarkUseCase: SheikhBookmarkUseCase


    init(
        surahBookmarkUseCase: SurahBookmarkUseCase,
        ayahBookmarkUseCase: AyahBookmarkUseCase,
        pageBookmarkUseCase: PageBookmarkUseCase,
        sheikhBookmarkUseCase: SheikhBookmarkUseCase
    ) {
        self.surahBookmarkUseCase = surahBookmarkUseCase
        self.ayahBookmarkUseCase = ayahBookmarkUseCase
        self.pageBookmarkUseCase = pageBookmarkUseCase
        self.sheikhBookmarkUseCase = sheikhBookmarkUseCase
        // Re-load whenever any module (e.g. Mushaf) mutates a bookmark so the
        // list stays fresh even if the user doesn't switch tabs.
        NotificationCenter.default.addObserver(
            forName: .bookmarkDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in self?.loadAll() }
        }
    }

    func loadAll() {
        do {
            surahBookmarks = try surahBookmarkUseCase.fetchAll()
            ayahBookmarks = try ayahBookmarkUseCase.fetchAll()
            pageBookmarks = try pageBookmarkUseCase.fetchAll()
            sheikhBookmarks = try sheikhBookmarkUseCase.fetchAll()
        } catch {
            errorMessage = "Failed to load bookmarks: \(error.localizedDescription)"
        }
    }

    func removeSurahBookmark(_ item: SurahBookmark) {
        do {
            try surahBookmarkUseCase.remove(surahNumber: item.surahNumber)
            surahBookmarks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
        }
    }

    func removeAyahBookmark(_ item: AyahBookmark) {
        do {
            try ayahBookmarkUseCase.remove(surahNumber: item.surahNumber, ayahNumber: item.ayahNumber)
            ayahBookmarks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
        }
    }

    func removePageBookmark(_ item: PageBookmark) {
        do {
            try pageBookmarkUseCase.remove(pageNumber: item.pageNumber)
            pageBookmarks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
        }
    }

    func removeSheikhBookmark(_ item: SheikhBookmark) {
        do {
            try sheikhBookmarkUseCase.remove(sheikhID: item.sheikhID)
            sheikhBookmarks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = "Failed to remove bookmark: \(error.localizedDescription)"
        }
    }

    // MARK: - Filtering

    var filteredSurahBookmarks: [SurahBookmark] {
        guard !searchText.isEmpty else { return surahBookmarks }
        return surahBookmarks.filter {
            $0.englishName.localizedCaseInsensitiveContains(searchText) || $0.arabicName.contains(searchText)
        }
    }

    var filteredAyahBookmarks: [AyahBookmark] {
        guard !searchText.isEmpty else { return ayahBookmarks }
        return ayahBookmarks.filter {
            $0.surahName.localizedCaseInsensitiveContains(searchText) ||
            $0.translation.localizedCaseInsensitiveContains(searchText) ||
            $0.arabicText.contains(searchText)
        }
    }

    var filteredPageBookmarks: [PageBookmark] {
        guard !searchText.isEmpty else { return pageBookmarks }
        return pageBookmarks.filter {
            $0.surahName.localizedCaseInsensitiveContains(searchText) || "\($0.pageNumber)".contains(searchText)
        }
    }

    var filteredSheikhBookmarks: [SheikhBookmark] {
        guard !searchText.isEmpty else { return sheikhBookmarks }
        return sheikhBookmarks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) || $0.arabicName.contains(searchText)
        }
    }

    var isCurrentTabEmpty: Bool {
        switch selectedTab {
        case .surah:  return filteredSurahBookmarks.isEmpty
        case .ayah:   return filteredAyahBookmarks.isEmpty
        case .page:   return filteredPageBookmarks.isEmpty
        case .sheikh: return filteredSheikhBookmarks.isEmpty
        }
    }
}
