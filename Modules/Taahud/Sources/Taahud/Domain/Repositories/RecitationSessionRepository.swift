import Foundation

/// Owns the WS lifecycle AND the mic capture/resample pipeline behind it, per
/// the mobile-team split agreed in API.md §10: mic permission + capture,
/// resample to 16kHz mono PCM16LE, open the socket, send `start`, stream
/// binary frames continuously, honor `seek`/`end`. No VAD, no chunking, no
/// accuracy logic here — that's entirely server-side.
public protocol RecitationSessionRepository: AnyObject, Sendable {
    /// Opens the socket, sends `start`, and begins streaming captured audio.
    /// Returns a stream the caller consumes until `.done` or `.closed`.
    func connect(config: TaahudSessionConfig) async throws -> AsyncStream<SessionEvent>

    /// Stops sending audio without closing the socket. The server keeps
    /// buffering nothing further; no message is sent to the server, since
    /// pause/resume is a purely local, client-side concept.
    func pauseCapture()

    /// Resumes sending audio frames after `pauseCapture()`.
    func resumeCapture() throws

    /// Reciter jumped elsewhere (page turn / āyah tap). Fire-and-forget.
    func seek(to position: MushafPosition)

    /// Sends `end`, stops capture. Caller must keep consuming the stream
    /// until `.done` arrives before tearing anything down further.
    func end()

    /// Hard local teardown (e.g. leaving the screen). Does not wait for `done`.
    func disconnect()
}
