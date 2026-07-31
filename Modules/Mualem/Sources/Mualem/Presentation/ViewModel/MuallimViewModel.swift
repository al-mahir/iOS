//
//  MuallimViewModel.swift
//  Mualem
//

import Foundation
import Combine

@MainActor
public final class MuallimViewModel: ObservableObject {
    @Published public var currentState: MuallimSessionState = .setup
    @Published public var config: MuallimSessionConfig?
    
    @Published public var currentAyahToProcess: Int = 0
    @Published public var currentRepetition: Int = 1
    @Published public var sessionStartPage: Int = 1
    @Published public var activeWordKey: String?
    
    // MARK: - Dependencies
    
    private var audioService: AudioPlaybackServiceProtocol
    private let evaluateUseCase: EvaluateRecitationUseCase
    private let ayahTextProvider: AyahTextProviding
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    public init(
        audioService: AudioPlaybackServiceProtocol,
        evaluateUseCase: EvaluateRecitationUseCase,
        ayahTextProvider: AyahTextProviding
    ) {
        self.audioService = audioService
        self.evaluateUseCase = evaluateUseCase
        self.ayahTextProvider = ayahTextProvider
        
        self.audioService.activeWordKeyPublisher
            .sink { [weak self] wordKey in
                guard self?.currentState == .listening else { return }
                self?.activeWordKey = wordKey
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Session Lifecycle
    
    public func startSession(config: MuallimSessionConfig) {
        self.config = config
        self.currentAyahToProcess = config.startAyah
        self.currentRepetition = 1
        self.sessionStartPage = Self.surahStartPages[config.surah - 1]
        startListeningPhase()
    }
    
    public func stopSession() {
        audioService.stop()
        evaluationTask?.cancel()
        currentState = .setup
        config = nil
    }
    
    // MARK: - Listening Phase
    
    private func startListeningPhase() {
        guard let _ = config else { return }
        currentState = .listening
        
        playReciterAudio()
    }
    
    private func playReciterAudio() {
        guard let config = config else { return }
        let qariId = config.qariId
        
        // Ensure the callback points to the *active* view model
        self.audioService.onPlaybackFinished = { [weak self] in
            Task { @MainActor in
                self?.handleAudioFinished()
            }
        }
        
        // Delegate fetching the correct audio URL and metadata to the service adapter.
        // Pass endAyah identical to startAyah so the adapter stops playback exactly after this single verse.
        audioService.loadAudio(
            surah: config.surah,
            startAyah: currentAyahToProcess,
            endAyah: currentAyahToProcess,
            qariId: qariId
        )
        
        // AudioSyncManager handles buffering internally when load and play are called sequentially.
        audioService.play()
    }
    
    private func handleAudioFinished() {
        guard currentState == .listening else { return }
        startRecordingPhase()
    }
    
    // MARK: - Recording Phase
    
    private var evaluationTask: Task<Void, Never>?
    
    private func startRecordingPhase() {
        currentState = .recording
        activeWordKey = nil
        
        evaluationTask = Task {
            let surah = config?.surah ?? 1
            
            // Fetch the expected words for this Ayah from the Quran database
            let expectedWords = ayahTextProvider.fetchNormalizedWords(
                surah: surah,
                ayah: currentAyahToProcess
            )
            
            // Max duration: use manual config or default to 60s (SFSpeechRecognizer limit)
            let maxDuration: TimeInterval
            if case .manual(let seconds) = config?.waitTime {
                maxDuration = TimeInterval(seconds)
            } else {
                maxDuration = 60.0
            }
            
            let stream = evaluateUseCase.execute(
                surah: surah,
                ayah: currentAyahToProcess,
                expectedWords: expectedWords,
                maxDuration: maxDuration
            )
            
            for await event in stream {
                if Task.isCancelled { break }
                
                switch event {
                case .wordDetected(let wordIndex):
                    activeWordKey = "\(surah):\(currentAyahToProcess):\(wordIndex)"
                case .completed(let mistakes):
                    currentState = .feedback(mistakes: mistakes)
                    activeWordKey = nil
                    
                    // Show feedback for 2 seconds, then transition
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    if !Task.isCancelled {
                        handleFeedbackFinished()
                    }
                case .error(let error):
                    print("Evaluation failed: \(error)")
                    if !Task.isCancelled {
                        handleFeedbackFinished()
                    }
                }
            }
        }
    }
    
    // MARK: - Feedback & Progression
    
    private func handleFeedbackFinished() {
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
