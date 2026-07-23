import Foundation

public enum StartTaahudSessionError: Error, Sendable {
    case microphonePermissionDenied
}

/// Story 1: Start Session. Verifies mic permission, then opens the session.
public struct StartTaahudSessionUseCase: Sendable {
    private let micPermission: MicrophonePermissionRepository
    private let sessionRepository: RecitationSessionRepository

    public init(micPermission: MicrophonePermissionRepository, sessionRepository: RecitationSessionRepository) {
        self.micPermission = micPermission
        self.sessionRepository = sessionRepository
    }

    public func execute(config: TaahudSessionConfig) async throws -> AsyncStream<SessionEvent> {
        guard micPermission.currentState() == .granted else {
            throw StartTaahudSessionError.microphonePermissionDenied
        }
        return try await sessionRepository.connect(config: config)
    }
}
