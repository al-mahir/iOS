//
//  TestSetupViewModel.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Foundation
import Combine
import Common

final class TestSetupViewModel: ObservableObject {
    enum ScopeKind: String, CaseIterable, Identifiable {
        case juz = "Juz'"
        case surahRange = "Surahs"
        case ayahRange = "Ayahs"
        var id: String { rawValue }
    }

    @Published var scopeKind: ScopeKind = .juz

    // Juz Selection
    @Published var selectedJuz: Int = 1

    // Surah Range Selection
    @Published var fromSurah: Int = 1 {
        didSet { enforceSurahOrder() }
    }
    @Published var toSurah: Int = 1 {
        didSet { enforceSurahOrder() }
    }

    // Ayah Range Selection
    @Published var ayahSurah: Int = 1 {
        didSet {
            resetAyahsForSurahChange()
        }
    }
    @Published var fromAyah: Int = 1 {
        didSet { enforceAyahOrder() }
    }
    @Published var toAyah: Int = 1 {
        didSet { enforceAyahOrder() }
    }

    // Question Configuration
    @Published var questionCount: Int = 5
    @Published private(set) var allowedQuestionRange: ClosedRange<Int>?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isResolving: Bool = false

    private let resolver: TestRangeResolver
    private let quranDataProvider: QuranDataProviderProtocol
    private var lastResolvedRange: ResolvedTestRange?

    init(
        resolver: TestRangeResolver,
        quranDataProvider: QuranDataProviderProtocol = QuranDataProvider.shared
    ) {
        self.resolver = resolver
        self.quranDataProvider = quranDataProvider
    }

    var availableSurahs: [Surah] {
        quranDataProvider.allSurahs
    }

    var maxAyahsForSelectedSurah: Int {
        quranDataProvider.surah(for: ayahSurah)?.ayahCount ?? 1
    }

    var currentScope: TestScope {
        switch scopeKind {
        case .juz:
            return .juz(selectedJuz)
        case .surahRange:
            return .surahRange(fromSurah: fromSurah, toSurah: toSurah)
        case .ayahRange:
            return .ayahRange(surah: ayahSurah, fromAyah: fromAyah, toAyah: toAyah)
        }
    }

    // MARK: - Validation & Invariant Handling

    private func enforceSurahOrder() {
        if fromSurah > toSurah {
            toSurah = fromSurah
        }
    }

    private func resetAyahsForSurahChange() {
        let maxCount = maxAyahsForSelectedSurah
        fromAyah = 1
        toAyah = maxCount
    }

    private func enforceAyahOrder() {
        let maxCount = maxAyahsForSelectedSurah
        
        // Clamp bounds inside 1...maxAyahs
        if fromAyah < 1 { fromAyah = 1 }
        if fromAyah > maxCount { fromAyah = maxCount }
        
        if toAyah < 1 { toAyah = 1 }
        if toAyah > maxCount { toAyah = maxCount }

        // Ensure start <= end
        if fromAyah > toAyah {
            toAyah = fromAyah
        }
    }

    // MARK: - Range Resolution

    func recomputeAllowedQuestionRange() {
        errorMessage = nil
        isResolving = true
        defer { isResolving = false }

        do {
            let resolved = try resolver.resolve(currentScope)
            lastResolvedRange = resolved
            guard let range = TestQuestionGenerator.allowedQuestionCountRange(for: resolved) else {
                allowedQuestionRange = nil
                errorMessage = "This range is too short for a test — please choose a wider range."
                return
            }
            allowedQuestionRange = range
            questionCount = min(max(questionCount, range.lowerBound), range.upperBound)
        } catch {
            allowedQuestionRange = nil
            lastResolvedRange = nil
            errorMessage = "Couldn't load this range. Please try another selection."
        }
    }

    func makeSession(wordsDAO: WordsDAO, layoutDAO: LayoutDAO, searchRepository: QuranSearchRepository) -> TestSessionManager? {
        guard let resolved = lastResolvedRange else {
            errorMessage = "Please choose a range first."
            return nil
        }
        do {
            let questions = try TestQuestionGenerator.generateQuestions(count: questionCount, from: resolved)
            let configuration = TestConfiguration(scope: currentScope, questionCount: questionCount)
            return TestSessionManager(
                configuration: configuration,
                questions: questions,
                wordsDAO: wordsDAO,
                layoutDAO: layoutDAO,
                searchRepository: searchRepository
            )
        } catch {
            errorMessage = "Couldn't generate questions for this selection."
            return nil
        }
    }
}
