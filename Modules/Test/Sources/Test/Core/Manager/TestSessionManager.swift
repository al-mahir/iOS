//
//  TestSessionManager.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import Foundation
import Common
import Combine
import SwiftUI

enum TestSessionPhase: Equatable {
    case notStarted
    case inProgress
    case finished
}

enum QuestionStatus {
    case answered
    case skipped
    case unanswered

    var title: String {
        switch self {
        case .answered: return "Answered"
        case .skipped: return "Skipped"
        case .unanswered: return "Not Answered"
        }
    }

    var icon: String {
        switch self {
        case .answered: return "checkmark.circle.fill"
        case .skipped: return "arrow.forward.circle.fill"
        case .unanswered: return "minus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .answered: return .green
        case .skipped: return .orange
        case .unanswered: return .gray
        }
    }
}

struct WordFeedback: Equatable {
    let spokenText: String
    let correctText: String
}

final class TestSessionManager: ObservableObject {
    // MARK: - Published state for the UI

    @Published private(set) var phase: TestSessionPhase = .notStarted
    @Published private(set) var currentQuestionNumber: Int = 0
    @Published private(set) var totalQuestions: Int = 0
    @Published private(set) var activeWord: TestWord?
    @Published private(set) var lastRevealedWordId: Int?
    @Published private(set) var lastSpokenText: String?
    @Published private(set) var lastWordWasCorrect: Bool?
    @Published private(set) var wordFeedback: WordFeedback?
    @Published private(set) var isReviewMode: Bool = false
    @Published private(set) var allQuestionsCompleted: Bool = false
    @Published private(set) var result: TestSessionResult?
    @Published var isMicMuted: Bool = true {
        didSet {
            handleMicMuteChange(isMuted: isMicMuted)
        }
    }

    // MARK: - Dependencies

    private let configuration: TestConfiguration
    private let questions: [TestQuestion]
    private let wordsDAO: WordsDAO
    private let searchRepository: QuranSearchRepository
    private let speechRecognizer: SpeechRecognizer

    // MARK: - Internal state

    private var currentQuestionIndex = 0
    private var reciteableWords: [TestWord] = []
    private var wordCursor = 0
    private var currentQuestionResult: QuestionResult?
    private var sessionResult: TestSessionResult
    private var questionStatuses: [QuestionStatus]
    private var cancellables = Set<AnyCancellable>()
    private var reviewCompletion: (() -> Void)?

    init(
        configuration: TestConfiguration,
        questions: [TestQuestion],
        wordsDAO: WordsDAO,
        searchRepository: QuranSearchRepository,
        speechRecognizer: SpeechRecognizer = SpeechRecognizer()
    ) {
        self.configuration = configuration
        self.questions = questions
        self.wordsDAO = wordsDAO
        self.searchRepository = searchRepository
        self.speechRecognizer = speechRecognizer
        self.totalQuestions = questions.count
        self.sessionResult = TestSessionResult(configuration: configuration)
        self.questionStatuses = Array(repeating: .unanswered, count: questions.count)

        speechRecognizer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Computed Properties for Review Flow

    var hasSkippedQuestions: Bool {
        questionStatuses.contains(.skipped) || questionStatuses.contains(.unanswered)
    }

    func statusForQuestion(at index: Int) -> QuestionStatus {
        guard index >= 0 && index < questionStatuses.count else { return .unanswered }
        return questionStatuses[index]
    }

    // MARK: - Lifecycle

    func start() {
        guard !questions.isEmpty, phase != .inProgress else { return }
        sessionResult = TestSessionResult(configuration: configuration)
        questionStatuses = Array(repeating: .unanswered, count: questions.count)
        allQuestionsCompleted = false
        isReviewMode = false
        wordFeedback = nil
        reviewCompletion = nil
        phase = .inProgress
        currentQuestionIndex = 0
        loadCurrentQuestion()
    }

    func cancel() {
        speechRecognizer.stopRecording()
        phase = .notStarted
        activeWord = nil
        wordFeedback = nil
    }

    /// Re-enters the session to answer just one question (used when the user
    /// taps a skipped/unanswered question from the review summary). The
    /// question's existing result is replaced in place once it's completed,
    /// and `completion` is called so the caller can re-present the summary.
    func startReview(questionIndex: Int, completion: @escaping () -> Void) {
        guard questionIndex >= 0 && questionIndex < questions.count, !isReviewMode else { return }
        isReviewMode = true
        reviewCompletion = completion
        currentQuestionIndex = questionIndex
        phase = .inProgress
        loadCurrentQuestion()
    }

    // MARK: - Question Flow & Actions

    func skipQuestion() {
        guard currentQuestionIndex < questions.count else { return }
        questionStatuses[currentQuestionIndex] = .skipped
        completeCurrentQuestion()
    }

    private func loadCurrentQuestion() {
        guard currentQuestionIndex < questions.count else {
            return
        }

        let question = questions[currentQuestionIndex]
        currentQuestionNumber = currentQuestionIndex + 1
        currentQuestionResult = QuestionResult(question: question)

        do {
            let rows = try wordsDAO.fetchWords(fromId: question.startWordId, toId: question.endWordId)
            reciteableWords = rows
                .map { TestWord(id: $0.id, surah: $0.surah, ayah: $0.ayah, wordPosition: $0.word, text: $0.text) }
                .filter { !$0.isVerseNumberMarker }
        } catch {
            reciteableWords = []
        }

        wordCursor = 0

        guard !reciteableWords.isEmpty else {
            completeCurrentQuestion()
            return
        }

        activeWord = reciteableWords[0]
        
        if !isMicMuted {
            startListening()
        }
    }

    private func handleMicMuteChange(isMuted: Bool) {
        if isMuted {
            speechRecognizer.stopRecording()
        } else if phase == .inProgress {
            startListening()
        }
    }

    private func startListening() {
        speechRecognizer.stopRecording()
        speechRecognizer.startRecording { [weak self] spokenText in
            self?.evaluate(spokenText: spokenText)
        }
    }

    private func evaluate(spokenText: String) {
        guard wordCursor < reciteableWords.count else { return }
        let word = reciteableWords[wordCursor]

        let cleaned = spokenText.unicodeScalars
            .filter { $0.value != 0x200F && $0.value != 0x200E && !$0.properties.isDefaultIgnorableCodePoint }
            .map(Character.init)
            .reduce(into: "") { $0.append($1) }
            .trimmingCharacters(in: .whitespacesAndNewlines)

        lastSpokenText = cleaned

        let searchWord = searchRepository.fetchSearchWord(id: word.id)
        let displayText = searchWord?.display.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedText = searchWord?.normalized.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let isCorrect = cleaned == displayText
            || cleaned == normalizedText
            || (!displayText.isEmpty && ArabicPhoneticMatcher.isPhoneticMatch(cleaned, displayText))
            || (!normalizedText.isEmpty && ArabicPhoneticMatcher.isPhoneticMatch(cleaned, normalizedText))

        lastWordWasCorrect = isCorrect
        lastRevealedWordId = word.id
        currentQuestionResult?.wordResults.append(
            WordAttemptResult(word: word, spokenText: cleaned, isCorrect: isCorrect)
        )

        if isCorrect {
            wordFeedback = nil
        } else {
            let correctText = !displayText.isEmpty ? displayText : word.text
            let feedback = WordFeedback(spokenText: cleaned, correctText: correctText)
            wordFeedback = feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                // Only clear if a newer piece of feedback hasn't already replaced it.
                if self?.wordFeedback == feedback {
                    self?.wordFeedback = nil
                }
            }
        }

        wordCursor += 1
        if wordCursor < reciteableWords.count {
            activeWord = reciteableWords[wordCursor]
        } else {
            if questionStatuses[currentQuestionIndex] != .skipped {
                questionStatuses[currentQuestionIndex] = .answered
            }
            completeCurrentQuestion()
        }
    }

    private func completeCurrentQuestion() {
        speechRecognizer.stopRecording()
        if let currentQuestionResult {
            // Replace the existing result for this question if it's being
            // re-answered (review mode), otherwise append as usual.
            if let existingIndex = sessionResult.questionResults.firstIndex(where: { $0.question.id == currentQuestionResult.question.id }) {
                sessionResult.questionResults[existingIndex] = currentQuestionResult
            } else {
                sessionResult.questionResults.append(currentQuestionResult)
            }
        }
        activeWord = nil
        wordFeedback = nil

        if isReviewMode {
            isReviewMode = false
            let completion = reviewCompletion
            reviewCompletion = nil
            completion?()
            return
        }

        currentQuestionIndex += 1

        if currentQuestionIndex < questions.count {
            loadCurrentQuestion()
        } else {
            allQuestionsCompleted = true
        }
    }

    func finalizeSession() {
        speechRecognizer.stopRecording()
        result = sessionResult
        phase = .finished
    }
}

// MARK: - Hashable (identity-based, for navigationDestination(item:))
extension TestSessionManager: Hashable {
    static func == (lhs: TestSessionManager, rhs: TestSessionManager) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
