//
//  TestSetupViewModel.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Foundation
import Common

final class TestSetupViewModel: ObservableObject {
    enum ScopeKind: String, CaseIterable, Identifiable {
        case juz = "Juz'"
        case surahRange = "Surahs"
        case ayahRange = "Ayahs"
        var id: String { rawValue }
    }

    @Published var scopeKind: ScopeKind = .juz

    @Published var selectedJuz: Int = 1

    @Published var fromSurah: Int = 1
    @Published var toSurah: Int = 1

    @Published var ayahSurah: Int = 1
    @Published var fromAyah: Int = 1
    @Published var toAyah: Int = 1

    @Published var questionCount: Int = 5

    @Published private(set) var allowedQuestionRange: ClosedRange<Int>?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isResolving: Bool = false

    private let resolver: TestRangeResolver
    private var lastResolvedRange: ResolvedTestRange?

    init(resolver: TestRangeResolver) {
        self.resolver = resolver
    }

    var currentScope: TestScope {
        switch scopeKind {
        case .juz:
            return .juz(selectedJuz)
        case .surahRange:
            return .surahRange(fromSurah: min(fromSurah, toSurah), toSurah: max(fromSurah, toSurah))
        case .ayahRange:
            return .ayahRange(surah: ayahSurah, fromAyah: min(fromAyah, toAyah), toAyah: max(fromAyah, toAyah))
        }
    }

    /// Call whenever the scope selection changes (juz/surah/ayah pickers) to
    /// refresh the selectable question-count range and surface any errors.
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

    /// Builds a ready-to-start session using the currently selected scope and
    /// question count. Returns nil (with `errorMessage` set) on failure.
    func makeSession(wordsDAO: WordsDAO, searchRepository: QuranSearchRepository) -> TestSessionManager? {
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
                searchRepository: searchRepository
            )
        } catch {
            errorMessage = "Couldn't generate questions for this selection."
            return nil
        }
    }
}
