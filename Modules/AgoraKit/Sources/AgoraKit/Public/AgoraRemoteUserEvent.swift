//
//  AgoraRemoteUserEvent.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public enum AgoraRemoteUserEvent: Equatable {
    case joined(user: AgoraRemoteUser)
    case left(uid: Int, reason: String)
    case mutedStateChanged(uid: Int, isMuted: Bool)
    case videoStateChanged(uid: Int, isEnabled: Bool)
    case volumeUpdated(uid: Int, audioLevel: Int)
}
