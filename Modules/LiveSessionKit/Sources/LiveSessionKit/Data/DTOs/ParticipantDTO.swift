//
//  ParticipantDTO.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct ParticipantDTO: Codable, Sendable {
    public let uid: Int
    public let name: String?
    public let avatarUrl: String?
    public let isHost: Bool?
    public let isMuted: Bool?
    public let isVideoEnabled: Bool?

    public init(
        uid: Int,
        name: String? = nil,
        avatarUrl: String? = nil,
        isHost: Bool? = nil,
        isMuted: Bool? = nil,
        isVideoEnabled: Bool? = nil
    ) {
        self.uid = uid
        self.name = name
        self.avatarUrl = avatarUrl
        self.isHost = isHost
        self.isMuted = isMuted
        self.isVideoEnabled = isVideoEnabled
    }
}
