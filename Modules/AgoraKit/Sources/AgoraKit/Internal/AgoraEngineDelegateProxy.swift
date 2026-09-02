//
//  AgoraEngineDelegateProxy.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import Combine
import AgoraRtcKit

internal final class AgoraEngineDelegateProxy: NSObject, AgoraRtcEngineDelegate {

    internal let connectionStateSubject = CurrentValueSubject<AgoraConnectionState, Never>(.disconnected)

    internal let remoteUserEventSubject = PassthroughSubject<AgoraRemoteUserEvent, Never>()

    internal var onTokenPrivilegeWillExpire: ((String) -> Void)?

    
    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didJoinChannel channel: String,
        withUid uid: UInt,
        elapsed: Int
    ) {
        connectionStateSubject.send(.connected)
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didJoinedOfUid uid: UInt,
        elapsed: Int
    ) {
        let user = AgoraRemoteUser(uid: Int(uid), audioLevel: 0, videoEnabled: false, isAudioMuted: false)
        remoteUserEventSubject.send(.joined(user: user))
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didOfflineOfUid uid: UInt,
        reason: AgoraUserOfflineReason
    ) {
        let reasonString: String
        switch reason {
        case .quit:
            reasonString = "User quit channel"
        case .dropped:
            reasonString = "Connection dropped"
        case .becomeAudience:
            reasonString = "Switched to audience"
        @unknown default:
            reasonString = "Unknown reason (\(reason.rawValue))"
        }
        remoteUserEventSubject.send(.left(uid: Int(uid), reason: reasonString))
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didAudioMuted muted: Bool,
        byUid uid: UInt
    ) {
        remoteUserEventSubject.send(.mutedStateChanged(uid: Int(uid), isMuted: muted))
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        remoteVideoStateChangedOfUid uid: UInt,
        state: AgoraVideoRemoteState,
        reason: AgoraVideoRemoteReason,
        elapsed: Int
    ) {
        switch state {
        case .starting, .decoding, .frozen:
            remoteUserEventSubject.send(.videoStateChanged(uid: Int(uid), isEnabled: true))
        case .stopped, .failed:
            remoteUserEventSubject.send(.videoStateChanged(uid: Int(uid), isEnabled: false))
        @unknown default:
            break
        }
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        tokenPrivilegeWillExpire token: String
    ) {
        onTokenPrivilegeWillExpire?(token)
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didOccurError errorCode: AgoraErrorCode
    ) {
        guard errorCode != .noError else { return }
        let sessionError = AgoraSessionError.sdkError(code: errorCode.rawValue)
        connectionStateSubject.send(.failed(sessionError))
    }

    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        connectionChangedTo state: AgoraRtcKit.AgoraConnectionState,
        reason: AgoraConnectionChangedReason
    ) {
        switch state {
        case .disconnected:
            connectionStateSubject.send(.disconnected)
        case .connecting:
            connectionStateSubject.send(.connecting)
        case .connected:
            connectionStateSubject.send(.connected)
        case .reconnecting:
            connectionStateSubject.send(.reconnecting)
        case .failed:
            let error = AgoraSessionError.sdkError(code: reason.rawValue)
            connectionStateSubject.send(.failed(error))
        @unknown default:
            break
        }
    }
}
