import Foundation

/// Story 9: Pause and Resume Session. Purely local — audio simply stops being
/// sent; the socket and server-side cursor are untouched.
public struct PauseTaahudSessionUseCase: Sendable {
    private let repository: RecitationSessionRepository
    public init(repository: RecitationSessionRepository) { self.repository = repository }
    public func execute() { repository.pauseCapture() }
}

public struct ResumeTaahudSessionUseCase: Sendable {
    private let repository: RecitationSessionRepository
    public init(repository: RecitationSessionRepository) { self.repository = repository }
    public func execute() throws { try repository.resumeCapture() }
}

/// Fired on page turn / āyah tap, and also used by reconnection to reseed
/// the cursor after an abnormal close (API.md §10 "Reconnection").
public struct SeekTaahudSessionUseCase: Sendable {
    private let repository: RecitationSessionRepository
    public init(repository: RecitationSessionRepository) { self.repository = repository }
    public func execute(to position: MushafPosition) { repository.seek(to: position) }
}

/// Story 10: Finish Session. Sends `end`; caller keeps consuming the event
/// stream until `.done` arrives before generating the summary.
public struct EndTaahudSessionUseCase: Sendable {
    private let repository: RecitationSessionRepository
    public init(repository: RecitationSessionRepository) { self.repository = repository }
    public func execute() { repository.end() }
}
