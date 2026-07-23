import Foundation

/// Drop-in stand-in for `RecitationSessionRepositoryImpl` while the AI/ASR
/// server is unavailable. Same protocol, so nothing in the domain,
/// use-case, or presentation layers needs to know or care — only
/// `TaahudDIContainer` decides which one gets built (see `useMockEngine`).
///
/// Takes its `audio: AudioCapturing` generically — `TaahudDIContainer` wires
/// it to `MockAudioCaptureEngine` (fully synthetic, no CoreAudio involved) so
/// this can run on any simulator regardless of host mic permissions. Story 2
/// (permission) still runs for real; only capture itself is faked, and story
/// 3's "listening…" indicator is driven by the synthetic engine's own timer.
final class MockRecitationSessionRepositoryImpl: RecitationSessionRepository, @unchecked Sendable {
    private let audio: AudioCapturing
    /// Simulated per-chunk latency, so the UI has time to render each step
    /// instead of the whole script landing at once.
    private let stepDelayNanoseconds: UInt64

    private var continuation: AsyncStream<SessionEvent>.Continuation?
    private var scriptTask: Task<Void, Never>?
    private var isPaused = false

    init(audio: AudioCapturing, stepDelaySeconds: Double = 1.6) {
        self.audio = audio
        self.stepDelayNanoseconds = UInt64(stepDelaySeconds * 1_000_000_000)
    }

    func connect(config: TaahudSessionConfig) async throws -> AsyncStream<SessionEvent> {
        let stream = AsyncStream<SessionEvent> { [weak self] continuation in
            self?.continuation = continuation
            continuation.onTermination = { [weak self] _ in self?.scriptTask?.cancel() }
        }

        audio.onPCMFrame = { _ in /* discarded — no server to send it to */ }
        try? audio.start()

        continuation?.yield(.ack(SessionAck(sessionId: "mock-\(UUID().uuidString)", engine: .mock, sampleRate: 16000)))
        runScript()

        return stream
    }

    func pauseCapture() {
        isPaused = true
        audio.pause()
    }

    func resumeCapture() throws {
        isPaused = false
        try audio.resume()
    }

    func seek(to position: MushafPosition) {
        // No-op: the script is a fixed timeline. A real server would jump
        // its cursor here; this stand-in has nowhere to jump to.
    }

    func end() {
        scriptTask?.cancel()
        audio.stop()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            self?.continuation?.yield(.done)
            self?.continuation?.finish()
        }
    }

    func disconnect() {
        scriptTask?.cancel()
        audio.stop()
        continuation?.finish()
    }

    private func runScript() {
        scriptTask = Task { [weak self] in
            guard let self else { return }
            for event in MockRecitationScript.events {
                while self.isPaused {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    if Task.isCancelled { return }
                }
                try? await Task.sleep(nanoseconds: self.stepDelayNanoseconds)
                if Task.isCancelled { return }
                self.continuation?.yield(.feedback(event))
            }
            // Script exhausted without the user tapping Finish: stay open and
            // idle rather than auto-ending, same as a real session would.
        }
    }
}
