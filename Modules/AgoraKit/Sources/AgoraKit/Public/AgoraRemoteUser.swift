//
//  AgoraRemoteUser.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public struct AgoraRemoteUser: Identifiable, Equatable, Sendable {

    public let uid: Int
    public var audioLevel: Int
    public var videoEnabled: Bool
    public var isAudioMuted: Bool

    public var id: Int { uid }

    public init(
        uid: Int,
        audioLevel: Int = 0,
        videoEnabled: Bool = false,
        isAudioMuted: Bool = false
    ) {
        self.uid = uid
        self.audioLevel = audioLevel
        self.videoEnabled = videoEnabled
        self.isAudioMuted = isAudioMuted
    }
}
