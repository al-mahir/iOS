//
//  SessionParticipant.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct SessionParticipant: Identifiable, Equatable, Sendable {
    public var id: Int { uid }
    public let uid: Int
    public var name: String?
    public var avatarUrl: String?
    public var isHost: Bool
    public var isMuted: Bool
    public var isVideoEnabled: Bool
    public var audioLevel: Int
    public var isMediaConnected: Bool
    public var isBackendConfirmed: Bool

    public var isFullyConnected: Bool {
        isMediaConnected && isBackendConfirmed
    }

    public init(
        uid: Int,
        name: String? = nil,
        avatarUrl: String? = nil,
        isHost: Bool = false,
        isMuted: Bool = false,
        isVideoEnabled: Bool = false,
        audioLevel: Int = 0,
        isMediaConnected: Bool = false,
        isBackendConfirmed: Bool = false
    ) {
        self.uid = uid
        self.name = name
        self.avatarUrl = avatarUrl
        self.isHost = isHost
        self.isMuted = isMuted
        self.isVideoEnabled = isVideoEnabled
        self.audioLevel = audioLevel
        self.isMediaConnected = isMediaConnected
        self.isBackendConfirmed = isBackendConfirmed
    }
}
