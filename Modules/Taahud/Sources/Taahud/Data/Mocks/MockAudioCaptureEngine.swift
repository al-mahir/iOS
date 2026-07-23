import Foundation

/// A fully synthetic `AudioCapturing` used only in mock mode.
///
/// The real `AudioCaptureEngine` touches `AVAudioEngine.inputNode`, which on
/// the iOS Simulator can trigger a CoreAudio HAL deadlock/abort
/// ("Initialize: RPC timeout. Apparently deadlocked. Aborting now.") when the
/// host Mac hasn't granted the Simulator microphone access. That's a hard
/// process abort at the OS layer — `try?`/`do-catch` cannot catch it.
///
/// Mock mode exists specifically to let the app run with zero external
/// dependencies, so it must not depend on real audio hardware either. This
/// type simulates the "listening…" indicator (story 3) with a plain timer
/// and never opens the microphone, never calls into AVFoundation.
final class MockAudioCaptureEngine: AudioCapturing, @unchecked Sendable {
    var onPCMFrame: (@Sendable (Data) -> Void)?
    var onLocalSpeechActivityChanged: (@Sendable (LocalSpeechActivity) -> Void)?

    private var timerTask: Task<Void, Never>?
    private var isRunning = false

    func start() throws {
        isRunning = true
        runActivityLoop()
    }

    func pause() {
        isRunning = false
    }

    func resume() throws {
        guard timerTask != nil else {
            try start()
            return
        }
        isRunning = true
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    private func runActivityLoop() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            var speaking = false
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 900_000_000)
                if Task.isCancelled { return }
                guard self.isRunning else { continue }
                speaking.toggle()
                self.onLocalSpeechActivityChanged?(speaking ? .speaking : .silent)
            }
        }
    }
}
