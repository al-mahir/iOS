//
//  ParticipantSocketEventDTO.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct ParticipantSocketEventDTO: Codable, Sendable {
    public let uid: Int
    public let name: String?
    public let avatarUrl: String?
    public let isHost: Bool?
    public let reason: String?

    public init(
        uid: Int,
        name: String? = nil,
        avatarUrl: String? = nil,
        isHost: Bool? = nil,
        reason: String? = nil
    ) {
        self.uid = uid
        self.name = name
        self.avatarUrl = avatarUrl
        self.isHost = isHost
        self.reason = reason
    }
}
