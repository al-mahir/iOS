//
//  LiveSession.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct LiveSession: Equatable, Sendable {
    public let circleId: String
    public let channelName: String
    public let uid: Int
    public let isHost: Bool
    public var participants: [SessionParticipant]
    public var isEnded: Bool

    public init(
        circleId: String,
        channelName: String,
        uid: Int,
        isHost: Bool,
        participants: [SessionParticipant] = [],
        isEnded: Bool = false
    ) {
        self.circleId = circleId
        self.channelName = channelName
        self.uid = uid
        self.isHost = isHost
        self.participants = participants
        self.isEnded = isEnded
    }
}
