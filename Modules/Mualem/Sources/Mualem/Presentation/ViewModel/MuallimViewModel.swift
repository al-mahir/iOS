//
//  MuallimViewModel.swift
//  Mualem
//
//  ViewModel orchestrating the AI Muallem session:
//  Sheikh recites → user repeats → AI grades → mistakes shown → repeat.
//

import Foundation
import Combine

@MainActor
public final class MuallimViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published public var currentState: MuallimSessionState = .setup
    @Published public var config: MuallimSessionConfig?
    
    @Published public var currentAyahToProcess: Int = 0
    @Published public var currentRepetition: Int = 1
    @Published public var sessionStartPage: Int = 1
    @Published public var activeWordKey: String?
    
    /// Per-word display status for live Mushaf coloring. Key format: "sura:aya:wordPosition" (1-based position)
    @Published public var wordStatuses: [String: WordDisplayStatus] = [:]
    
    /// Triggers the mistakes bottom sheet
    @Published public var showMistakesSheet: Bool = false {
        didSet {
            if showMistakesSheet {
                autoContinueTask?.cancel()
                autoContinueTask = nil
            }
        }
    }
    
    /// Current ayah's feedback result for the mistakes sheet
    @Published public var currentFeedbackResult: AyahFeedbackResult?
    
    /// Accumulated results across all ayahs/reps for the session summary
    @Published public var accumulatedResults: [AyahFeedbackResult] = []
    @Published public var showSummarySheet: Bool = false
    
    /// AI server connection status
    @Published public var isServerConnected: Bool = false
    
    /// Which AI engine is active for this session
    @Published public var currentEngine: String?
    
    /// Health info from the AI service
    @Published public var healthInfo: AIHealthInfo?
    
    /// User-selected strictness level
    @Published public var selectedStrictness: RecitationStrictness = .normal
    
    /// Words detected so far in current recording phase
    @Published public var detectedWordCount: Int = 0
    @Published public var totalExpectedWords: Int = 0
    
    // MARK: - Dependencies
    
    private var audioService: AudioPlaybackServiceProtocol
    private let sessionUseCase: StartMuallemSessionUseCase
    private let configUseCase: FetchAIConfigUseCase
    private let audioCaptureService: AudioCaptureService
    private let ayahTextProvider: AyahTextProviding
    private let localSpeechService: VoiceEvaluationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private State
    
    private var sessionTask: Task<Void, Never>?
    private var audioStreamTask: Task<Void, Never>?
    private var speechTask: Task<Void, Never>?
    private var autoContinueTask: Task<Void, Never>?
    private var lastCursor: QuranPosition?
    private var currentChunkWords: [WordFeedback] = []
    private var speechWordPosition: Int = 0
    
    // MARK: - Init
    
    init(
        audioService: AudioPlaybackServiceProtocol,
        sessionUseCase: StartMuallemSessionUseCase,
        configUseCase: FetchAIConfigUseCase,
        audioCaptureService: AudioCaptureService,
        ayahTextProvider: AyahTextProviding,
        localSpeechService: VoiceEvaluationServiceProtocol = SFSpeechEvaluationService()
    ) {
        self.audioService = audioService
        self.sessionUseCase = sessionUseCase
        self.configUseCase = configUseCase
        self.audioCaptureService = audioCaptureService
        self.ayahTextProvider = ayahTextProvider
        self.localSpeechService = localSpeechService
        
        // Forward active word key from audio playback (sheikh phase)
        self.audioService.activeWordKeyPublisher
            .sink { [weak self] wordKey in
                guard self?.currentState == .listening else { return }
                self?.activeWordKey = wordKey
            }
            .store(in: &cancellables)
            
        // Wire voice-activated word highlighting (Taahud engine pattern)
        self.audioCaptureService.onLocalSpeechActivityChanged = { [weak self] activity in
            Task { @MainActor in
                guard let self = self, self.currentState == .recording, let config = self.config else { return }
                if activity == .speaking {
                    if self.activeWordKey == nil {
                        self.speechWordPosition = 1
                        self.activeWordKey = "\(config.surah):\(self.currentAyahToProcess):1"
                    } else if self.speechWordPosition < self.totalExpectedWords {
                        self.speechWordPosition += 1
                        self.activeWordKey = "\(config.surah):\(self.currentAyahToProcess):\(self.speechWordPosition)"
                    }
                }
            }
        }
        
        // Check AI server health on init
        Task { await checkServerHealth() }
    }
    
    // MARK: - Server Health
    
    private func checkServerHealth() async {
        do {
            let health = try await configUseCase.fetchHealth()
            healthInfo = health
            isServerConnected = health.isHealthy
        } catch {
            healthInfo = nil
            isServerConnected = false
        }
    }
    
    // MARK: - Session Lifecycle
    
    public func startSession(config: MuallimSessionConfig) {
        self.config = config
        self.currentAyahToProcess = config.startAyah
        self.currentRepetition = 1
        self.sessionStartPage = Self.surahStartPages[config.surah - 1]
        self.accumulatedResults = []
        self.wordStatuses = [:]
        self.lastCursor = nil
        startListeningPhase()
    }
    
    public func stopSession() {
        audioService.stop()
        audioCaptureService.stopCapture()
        sessionTask?.cancel()
        audioStreamTask?.cancel()
        speechTask?.cancel()
        speechTask = nil
        autoContinueTask?.cancel()
        autoContinueTask = nil
        sessionUseCase.endSession()
        currentState = .setup
        config = nil
        wordStatuses = [:]
        currentFeedbackResult = nil
        showMistakesSheet = false
        showSummarySheet = false
        detectedWordCount = 0
    }
    
    public func continuePastFeedback() {
        autoContinueTask?.cancel()
        autoContinueTask = nil
        showMistakesSheet = false
        handleFeedbackFinished()
    }
    
    public func dismissMistakesSheet() {
        showMistakesSheet = false
    }
    
    // MARK: - Listening Phase (Sheikh Recites)
    
    private func startListeningPhase() {
        guard let _ = config else { return }
        audioCaptureService.stopCapture()
        audioStreamTask?.cancel()
        speechTask?.cancel()
        
        currentState = .listening
        activeWordKey = nil
        wordStatuses = [:]
        detectedWordCount = 0
        
        playReciterAudio()
    }
    
    private func playReciterAudio() {
        guard let config = config else { return }
        let qariId = config.qariId
        
        self.audioService.onPlaybackFinished = { [weak self] in
            Task { @MainActor in
                self?.handleAudioFinished()
            }
        }
        
        audioService.loadAudio(
            surah: config.surah,
            startAyah: currentAyahToProcess,
            endAyah: currentAyahToProcess,
            qariId: qariId
        )
    }
    
    private func handleAudioFinished() {
        guard currentState == .listening else { return }
        startRecordingPhase()
    }
    
    // MARK: - Recording Phase (User Recites + AI Evaluates)
    
    private func startRecordingPhase() {
        currentState = .recording
        activeWordKey = nil
        currentChunkWords = []
        speechWordPosition = 0
        
        guard let config = config else { return }
        
        let expectedWords = ayahTextProvider.fetchNormalizedWords(
            surah: config.surah,
            ayah: currentAyahToProcess
        )
        totalExpectedWords = max(expectedWords.count, 1)
        
        // Build WS session config
        let wsConfig = MuallemWSSessionConfig(
            sura: config.surah,
            aya: currentAyahToProcess,
            wordIdx: lastCursor?.wordIdx ?? 0,
            strictness: selectedStrictness,
            engine: currentEngine
        )
        
        // Start the WebSocket session
        let eventStream = sessionUseCase.execute(config: wsConfig)
        
        // Start mic capture and pipe audio to the session
        let audioStream = audioCaptureService.startCapture()
        
        // Start local SFSpeechRecognizer for instant real-time Arabic word-by-word highlighting
        let speechStream = localSpeechService.evaluateStream(
            surah: config.surah,
            ayah: currentAyahToProcess,
            expectedWords: expectedWords,
            maxDuration: 60.0
        )
        
        speechTask = Task { @MainActor [weak self] in
            for await event in speechStream {
                guard let self = self, self.currentState == .recording else { break }
                if case .wordDetected(let wordIndex) = event {
                    self.activeWordKey = "\(config.surah):\(self.currentAyahToProcess):\(wordIndex)"
                }
            }
        }
        
        audioStreamTask = Task {
            for await pcmData in audioStream {
                if Task.isCancelled { break }
                sessionUseCase.sendAudio(pcmData)
            }
        }
        
        // Listen for feedback events
        sessionTask = Task {
            for await event in eventStream {
                if Task.isCancelled { break }
                handleSessionEvent(event)
            }
        }
        
        // Auto-stop after max duration (adaptive to expected word count instead of 60s)
        let maxDuration: TimeInterval
        if case .manual(let seconds) = config.waitTime {
            maxDuration = TimeInterval(seconds)
        } else {
            maxDuration = max(12.0, Double(totalExpectedWords) * 2.5)
        }
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(maxDuration * 1_000_000_000))
            if currentState == .recording {
                finishRecording()
            }
        }
    }
    
    private func handleSessionEvent(_ event: MuallemSessionEvent) {
        switch event {
        case .sessionAck(_, let engine, _):
            currentEngine = engine
            isServerConnected = !engine.contains("mock")
            
        case .feedback(let feedback):
            processFeedback(feedback)
            
        case .done:
            if currentState == .recording || currentState == .evaluating {
                presentFeedback()
            }
            
        case .error(let error):
            print("AI session error: \(error.localizedDescription)")
            if currentState == .recording {
                // Fall through to feedback with whatever we have
                presentFeedback()
            }
        }
    }
    
    private func processFeedback(_ feedback: RecitationFeedback) {
        // Update cursor
        if let cursor = feedback.cursor {
            lastCursor = cursor
        }
        
        // Update or append words by position (sura, aya, wordIdx) so streamed chunks update existing words
        for word in feedback.words {
            if let index = currentChunkWords.firstIndex(where: { $0.sura == word.sura && $0.aya == word.aya && $0.wordIdx == word.wordIdx }) {
                currentChunkWords[index] = word
            } else {
                currentChunkWords.append(word)
            }
        }
        currentChunkWords.sort { $0.wordIdx < $1.wordIdx }
        
        // Update live word statuses on the Mushaf
        for word in feedback.words {
            let key = word.position.mushafWordKey
            wordStatuses[key] = word.displayStatus
        }
        
        detectedWordCount = currentChunkWords.count
        
        // If all expected words for this Ayah have been received, auto-finish after 1.5s
        if detectedWordCount >= totalExpectedWords && currentState == .recording {
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if currentState == .recording {
                    finishRecording()
                }
            }
        }
    }
    
    public func finishRecording() {
        guard currentState == .recording else { return }
        currentState = .evaluating
        speechTask?.cancel()
        speechTask = nil
        
        // Stop mic capture
        audioCaptureService.stopCapture()
        audioStreamTask?.cancel()
        
        // Tell AI service to flush
        sessionUseCase.endSession()
        
        // Safety timeout: if done event doesn't arrive in 5s, force present feedback
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if currentState == .evaluating {
                presentFeedback()
            }
        }
    }
    
    private func presentFeedback() {
        guard let config = config else { return }
        
        // Build the ayah text
        let expectedWords = ayahTextProvider.fetchNormalizedWords(
            surah: config.surah,
            ayah: currentAyahToProcess
        )
        let ayahText = expectedWords.joined(separator: " ")
        
        let finalWords: [WordFeedback]
        if currentChunkWords.isEmpty {
            // No words evaluated by AI engine — populate fallback words so Ayah text is displayed
            finalWords = expectedWords.enumerated().map { (idx, wordText) in
                WordFeedback(
                    sura: config.surah,
                    aya: currentAyahToProcess,
                    wordIdx: idx,
                    uthmani: wordText,
                    status: .almost,
                    isTrimmed: true,
                    errors: []
                )
            }
        } else {
            finalWords = currentChunkWords
        }
        
        let result = AyahFeedbackResult(
            words: finalWords,
            ayahText: ayahText,
            sura: config.surah,
            aya: currentAyahToProcess,
            nonVerse: finalWords.isEmpty ? [] :
                Array(Set(finalWords.flatMap { _ in [String]() }))
        )
        
        currentFeedbackResult = result
        accumulatedResults.append(result)
        currentState = .feedback(result: result)
        
        autoContinueTask?.cancel()
        autoContinueTask = nil
        
        // Show mistakes sheet if there are any errors
        if result.errorCount > 0 || result.hintCount > 0 {
            showMistakesSheet = true
        } else {
            // Perfect recitation — auto-continue after a brief celebration
            autoContinueTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard let self = self, !Task.isCancelled else { return }
                if case .feedback = self.currentState {
                    self.handleFeedbackFinished()
                }
            }
        }
    }
    
    // MARK: - Feedback & Progression
    
    private func handleFeedbackFinished() {
        guard case .feedback = currentState else { return }
        autoContinueTask?.cancel()
        autoContinueTask = nil
        guard let config = config else { return }
        
        // Condition A: Repeat Current Ayah
        if currentRepetition < config.repetitions {
            currentRepetition += 1
            startListeningPhase()
        }
        // Condition B: Move to Next Ayah or Finish
        else {
            if currentAyahToProcess < config.endAyah {
                currentAyahToProcess += 1
                currentRepetition = 1
                startListeningPhase()
            } else {
                currentState = .completed
                showSummarySheet = true
            }
        }
    }
    
    // MARK: - Surah → Mushaf Page Mapping (Madani Mushaf)
    
    /// The starting page of each surah in the standard Madani Mushaf (index 0 = Surah 1).
    private static let surahStartPages: [Int] = [
        1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
        221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
        322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
        411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
        477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
        520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
        551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
        570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
        586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
        595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
        600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
        603, 604, 604, 604
    ]
}
