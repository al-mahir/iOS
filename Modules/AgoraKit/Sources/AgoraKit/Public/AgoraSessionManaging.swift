//
//  AgoraSessionManaging.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import Combine
import UIKit

public protocol AgoraSessionManaging: AnyObject {
    var connectionStatePublisher: AnyPublisher<AgoraConnectionState, Never> { get }
    var remoteUserEventsPublisher: AnyPublisher<AgoraRemoteUserEvent, Never> { get }
    
    var onTokenPrivilegeWillExpire: ((String) -> Void)? { get set }

    var currentConnectionState: AgoraConnectionState { get }

    func requestMediaPermissions(includeVideo: Bool) async -> AgoraMediaPermissionResult

    func join(channelName: String, token: String, uid: Int) async throws
    func leave() async throws
    func muteLocalAudio(_ muted: Bool)
    func enableLocalVideo(_ enabled: Bool)

    /// Binds local camera preview track to a host `UIView`.
    /// - Parameter view: The target `UIView` container for rendering local video.
    /// - Returns: `true` if setup succeeded; `false` otherwise.
    @discardableResult
    func setupLocalVideoCanvas(_ view: UIView) -> Bool

    /// Binds a remote user's video track to a host `UIView`.
    /// - Parameters:
    ///   - view: The target `UIView` container for rendering remote video.
    ///   - uid: The numeric user ID of the remote participant.
    /// - Returns: `true` if setup succeeded; `false` otherwise.
    @discardableResult
    func setupRemoteVideoCanvas(_ view: UIView, forUid uid: Int) -> Bool
}

public extension AgoraSessionManaging {
    func requestMediaPermissions(includeVideo: Bool = false) async -> AgoraMediaPermissionResult {
        await requestMediaPermissions(includeVideo: includeVideo)
    }
}
