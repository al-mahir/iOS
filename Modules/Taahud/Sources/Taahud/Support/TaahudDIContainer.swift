import Foundation

/// Composition root for the Ta'ahud feature. Nothing above this layer needs
/// to know about URLSession, AVAudioEngine, or JSON — only the domain
/// protocols, per Clean Architecture's dependency rule (Presentation and
/// Data both depend inward on Domain; Domain depends on nothing).
struct TaahudEnvironment {
    /// e.g. http://192.168.1.20:8100 — configurable per SETUP.md/API.md §1,
    /// since a gateway may later sit in front and add a path prefix.
    let baseHTTPURL: URL
    let baseWSURL: URL
    /// TEMPORARY: the AI/ASR server is currently down. While `true`, sessions
    /// run against `MockRecitationSessionRepositoryImpl`'s scripted feedback
    /// instead of the real WS endpoint — same protocol, same UI, canned
    /// grading. Flip back to `false` the moment the server is back; nothing
    /// else in the app needs to change.
    var useMockEngine: Bool

    static func makeDefault(useMockEngine: Bool = true) -> TaahudEnvironment {
        TaahudEnvironment(
            baseHTTPURL: URL(string: "http://localhost:8100")!,
            baseWSURL: URL(string: "ws://localhost:8100")!,
            useMockEngine: useMockEngine
        )
    }
}

@MainActor
final class TaahudDIContainer {
    let environment: TaahudEnvironment

    let micPermissionRepository: MicrophonePermissionRepository
    let settingsRepository: TaahudSettingsRepository
    let historyRepository: SessionHistoryRepository

    init(environment: TaahudEnvironment = .makeDefault()) {
        self.environment = environment
        self.micPermissionRepository = MicrophonePermissionServiceImpl()
        self.settingsRepository = TaahudSettingsAPIClient(baseURL: environment.baseHTTPURL)
        self.historyRepository = SessionHistoryRepositoryImpl()
    }

    /// A fresh session repository + audio engine per session — these are not
    /// meant to be reused across sessions. The same `audio` instance is
    /// shared with the view model so its local speech-activity callback
    /// reflects the mic that is actually capturing.
    private func makeSessionRepository(audio: AudioCapturing) -> RecitationSessionRepository {
        if environment.useMockEngine {
            return MockRecitationSessionRepositoryImpl(audio: audio)
        }
        let wsURL = environment.baseWSURL.appendingPathComponent("ws/session")
        return RecitationSessionRepositoryImpl(
            socket: RecitationWebSocketClient(),
            audio: audio,
            wsURL: wsURL
        )
    }

    func makeSessionViewModel(config: TaahudSessionConfig) -> TaahudSessionViewModel {
        let audio: AudioCapturing = environment.useMockEngine ? MockAudioCaptureEngine() : AudioCaptureEngine()
        let sessionRepository = makeSessionRepository(audio: audio)

        return TaahudSessionViewModel(
            config: config,
            requestMicPermission: RequestMicrophonePermissionUseCase(repository: micPermissionRepository),
            startSession: StartTaahudSessionUseCase(micPermission: micPermissionRepository, sessionRepository: sessionRepository),
            pauseSession: PauseTaahudSessionUseCase(repository: sessionRepository),
            resumeSession: ResumeTaahudSessionUseCase(repository: sessionRepository),
            seekSession: SeekTaahudSessionUseCase(repository: sessionRepository),
            endSession: EndTaahudSessionUseCase(repository: sessionRepository),
            generateSummary: GenerateSessionSummaryUseCase(),
            saveHistory: SaveSessionHistoryUseCase(repository: historyRepository),
            audio: audio
        )
    }

    func makeSummaryViewModel(summary: SessionSummary) -> TaahudSummaryViewModel {
        TaahudSummaryViewModel(summary: summary)
    }
}
