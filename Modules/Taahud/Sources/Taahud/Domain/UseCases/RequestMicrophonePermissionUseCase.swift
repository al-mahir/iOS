import Foundation

/// Story 2: Request Microphone Permission.
public struct RequestMicrophonePermissionUseCase: Sendable {
    private let repository: MicrophonePermissionRepository

    public init(repository: MicrophonePermissionRepository) {
        self.repository = repository
    }

    public func execute() async -> MicrophonePermissionState {
        let current = repository.currentState()
        if current != .notDetermined { return current }
        return await repository.requestPermission()
    }
}
