//
//  TestSessionManager.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Foundation
import Common
import Combine

enum TestSessionPhase: Equatable {
    case notStarted
    case inProgress
    case finished
}

final class TestSessionManager: ObservableObject {
    // MARK: - Published state for the UI

    @Published private(set) var phase: TestSessionPhase = .notStarted
    @Published private(set) var currentQuestionNumber: Int = 0
    @Published private(set) var totalQuestions: Int = 0
    @Published private(set) var activeWord: TestWord?
    /// Word id of the most recently evaluated word, for UI highlighting —
    /// advances on every attempt (correct or not), since test mode never retries.
    @Published private(set) var lastRevealedWordId: Int?
    @Published private(set) var lastSpokenText: String?
    @Published private(set) var lastWordWasCorrect: Bool?
    @Published private(set) var result: TestSessionResult?

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
    private var cancellables = Set<AnyCancellable>()

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

        speechRecognizer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle

    func start() {
        guard !questions.isEmpty, phase != .inProgress else { return }
        sessionResult = TestSessionResult(configuration: configuration)
        phase = .inProgress
        currentQuestionIndex = 0
        loadCurrentQuestion()
    }

    func cancel() {
        speechRecognizer.stopRecording()
        phase = .notStarted
        activeWord = nil
    }

    // MARK: - Question flow

    private func loadCurrentQuestion() {
        guard currentQuestionIndex < questions.count else {
            finish()
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

        wordCursor += 1
        if wordCursor < reciteableWords.count {
            activeWord = reciteableWords[wordCursor]
        } else {
            completeCurrentQuestion()
        }
    }

    private func completeCurrentQuestion() {
        speechRecognizer.stopRecording()
        if let currentQuestionResult {
            sessionResult.questionResults.append(currentQuestionResult)
        }
        activeWord = nil
        currentQuestionIndex += 1
        loadCurrentQuestion()
    }

    private func finish() {
        speechRecognizer.stopRecording()
        result = sessionResult
        phase = .finished
    }
}
