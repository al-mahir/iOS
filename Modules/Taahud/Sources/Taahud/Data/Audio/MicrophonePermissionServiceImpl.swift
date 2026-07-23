import AVFAudio

/// Story 2: Request Microphone Permission.
final class MicrophonePermissionServiceImpl: MicrophonePermissionRepository, @unchecked Sendable {

    func currentState() -> MicrophonePermissionState {
        if #available(iOS 17.0, *) {
            return map(AVAudioApplication.shared.recordPermission)
        } else {
            return map(AVAudioSession.sharedInstance().recordPermission)
        }
    }

    func requestPermission() async -> MicrophonePermissionState {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted ? .granted : .denied)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted ? .granted : .denied)
                }
            }
        }
    }

    @available(iOS 17.0, *)
    private func map(_ permission: AVAudioApplication.recordPermission) -> MicrophonePermissionState {
        switch permission {
        case .undetermined: return .notDetermined
        case .granted: return .granted
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    private func map(_ permission: AVAudioSession.RecordPermission) -> MicrophonePermissionState {
        switch permission {
        case .undetermined: return .notDetermined
        case .granted: return .granted
        case .denied: return .denied
        @unknown default: return .denied
        }
    }
}
