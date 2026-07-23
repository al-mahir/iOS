import Foundation
import Combine

@MainActor
final class TaahudSessionViewModel: ObservableObject {

    // MARK: Published state consumed by the view

    @Published private(set) var phase: TaahudSessionPhase = .idle
    @Published private(set) var currentWords: [WordFeedback] = []      // story 7: live highlighting
    @Published private(set) var selectedMistake: MistakeRecord?        // story 8 (view mistake detail)
    @Published private(set) var runningAccuracy: Double = 0            // story 8 (continuous update)
    @Published private(set) var localSpeechActivity: LocalSpeechActivity = .silent // story 3, UI-only
    @Published private(set) var lastAckedEngine: ASREngine?
    @Published private(set) var engineMismatchWarning: String?
    @Published private(set) var summary: SessionSummary?
    @Published private(set) var toastMessage: String?

    // MARK: Dependencies

    private let requestMicPermission: RequestMicrophonePermissionUseCase
    private let startSession: StartTaahudSessionUseCase
    private let pauseSession: PauseTaahudSessionUseCase
    private let resumeSession: ResumeTaahudSessionUseCase
    private let seekSession: SeekTaahudSessionUseCase
    private let endSession: EndTaahudSessionUseCase
    private let generateSummary: GenerateSessionSummaryUseCase
    private let saveHistory: SaveSessionHistoryUseCase
    private let audio: AudioCapturing

    // MARK: Session-scoped state

    private var config: TaahudSessionConfig
    private var sessionId: String?
    private var startedAt: Date?
    private var lastCursor: MushafPosition?
    private var collectedEvents: [FeedbackEvent] = []
    private var scoredWordCount = 0
    private var correctWordCount = 0
    private var consumeTask: Task<Void, Never>?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3

    init(
        config: TaahudSessionConfig,
        requestMicPermission: RequestMicrophonePermissionUseCase,
        startSession: StartTaahudSessionUseCase,
        pauseSession: PauseTaahudSessionUseCase,
        resumeSession: ResumeTaahudSessionUseCase,
        seekSession: SeekTaahudSessionUseCase,
        endSession: EndTaahudSessionUseCase,
        generateSummary: GenerateSessionSummaryUseCase,
        saveHistory: SaveSessionHistoryUseCase,
        audio: AudioCapturing
    ) {
        self.config = config
        self.requestMicPermission = requestMicPermission
        self.startSession = startSession
        self.pauseSession = pauseSession
        self.resumeSession = resumeSession
        self.seekSession = seekSession
        self.endSession = endSession
        self.generateSummary = generateSummary
        self.saveHistory = saveHistory
        self.audio = audio

        audio.onLocalSpeechActivityChanged = { [weak self] activity in
            Task { @MainActor in self?.localSpeechActivity = activity }
        }
    }

    // MARK: Story 1 & 2 — start

    func start() async {
        phase = .requestingMicPermission
        let permission = await requestMicPermission.execute()
        guard permission == .granted else {
            phase = .micPermissionDenied
            return
        }

        phase = .connecting
        await openSession()
    }

    private func openSession() async {
        do {
            let stream = try await startSession.execute(config: config)
            startedAt = Date()
            listen(to: stream)
        } catch {
            phase = .failed("Could not start the session: \(error.localizedDescription)")
        }
    }

    private func listen(to stream: AsyncStream<SessionEvent>) {
        consumeTask?.cancel()
        consumeTask = Task { [weak self] in
            guard let self else { return }
            for await event in stream {
                await self.handle(event)
            }
        }
    }

    private func handle(_ event: SessionEvent) async {
        switch event {
        case .ack(let ack):
            sessionId = ack.sessionId
            lastAckedEngine = ack.engine
            if let requested = config.engine, requested != ack.engine {
                engineMismatchWarning = "Requested \(requested.rawValue), server is running \(ack.engine.rawValue)."
            }
            phase = .active

        case .feedback(let feedbackEvent):
            collectedEvents.append(feedbackEvent)
            if let cursor = feedbackEvent.cursor { lastCursor = cursor }
            applyToUI(feedbackEvent)

        case .done:
            await finalizeSummary()

        case .closed(let code, _):
            await handleClosedSocket(code: code)

        case .transportError(let description):
            toastMessage = "Connection problem (\(description)). Trying to recover…"
        }
    }

    /// Story 7 (live highlighting) + story 8 (continuous performance update).
    /// Applies the three rendering rules from API.md §5.5: `almost` is a hint
    /// only, `trimmed` is neutral/unverified, `ambiguous`/`no_match` marks
    /// nothing at all.
    private func applyToUI(_ event: FeedbackEvent) {
        guard event.feedback.status == .ok else {
            // ambiguous / no_match: show a neutral state upstream (the view
            // reads `feedback.status` directly for its "didn't catch that" /
            // candidate-picker UI); nothing is scored or marked here.
            return
        }

        currentWords = event.feedback.words

        for word in event.feedback.words where !word.trimmed {
            scoredWordCount += 1
            if word.status == .correct { correctWordCount += 1 }
        }
        runningAccuracy = scoredWordCount > 0 ? Double(correctWordCount) / Double(scoredWordCount) : 0
    }

    // MARK: Story 8 — mistake detail

    func selectMistake(_ mistake: MistakeRecord) {
        selectedMistake = mistake
    }

    func clearSelectedMistake() {
        selectedMistake = nil
    }

    // MARK: Story 9 — pause / resume

    func pause() {
        guard phase == .active else { return }
        pauseSession.execute()
        phase = .paused
    }

    func resume() {
        guard phase == .paused else { return }
        do {
            try resumeSession.execute()
            phase = .active
        } catch {
            phase = .failed("Could not resume the microphone: \(error.localizedDescription)")
        }
    }

    // MARK: Seeking (page turn / āyah tap)

    func seek(to position: MushafPosition) {
        seekSession.execute(to: position)
    }

    // MARK: Story 10 — finish

    func finish() {
        guard phase == .active || phase == .paused else { return }
        phase = .ending
        endSession.execute()
        // Wait for `.done` on the existing stream — do not tear down here,
        // or the last chunk of the recitation is lost (API.md §5.8).
    }

    private func finalizeSummary() async {
        guard let sessionId, let startedAt else { return }
        let result = generateSummary.execute(
            sessionId: sessionId,
            startedAt: startedAt,
            endedAt: Date(),
            engineUsed: lastAckedEngine ?? .mock,
            strictness: config.strictness,
            startPosition: config.position,
            events: collectedEvents
        )
        summary = result
        phase = .finished
        try? await saveHistory.execute(result)
    }

    // MARK: Story 15 — recover from recognition failures

    private func handleClosedSocket(code: Int) async {
        switch code {
        case 1000:
            // Normal close after done; if we get here without having seen
            // `.done` the socket still closed cleanly, so just finalize.
            if summary == nil { await finalizeSummary() }
        case 1002:
            // Protocol error — a client bug, not transient. Do not retry.
            phase = .failed("The session could not continue due to a protocol error.")
        default:
            // 1006 and anything else: reconnect using the last known cursor
            // so the reciter resumes where they actually are, per API.md
            // §10 "Reconnection", without losing progress made so far.
            await attemptReconnect()
        }
    }

    private func attemptReconnect() async {
        guard reconnectAttempts < maxReconnectAttempts else {
            phase = .failed("Lost connection to the recitation service.")
            return
        }
        reconnectAttempts += 1
        toastMessage = "Reconnecting…"

        var resumedConfig = config
        if let lastCursor {
            resumedConfig.position = lastCursor
        }
        config = resumedConfig

        phase = .connecting
        await openSession()
    }
}
