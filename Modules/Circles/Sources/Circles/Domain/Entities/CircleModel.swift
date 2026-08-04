//
//  Circle.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public struct CircleModel: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let status: CircleStatus
    public let type: CircleType
    public let requiresApproval: Bool
    public let maxParticipants: Int
    public let channelName: String
    public let ownerId: String
    public let memberCount: Int

    public init(
        id: String,
        name: String,
        startDate: Date,
        endDate: Date,
        status: CircleStatus,
        type: CircleType,
        requiresApproval: Bool,
        maxParticipants: Int,
        channelName: String,
        ownerId: String,
        memberCount: Int
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.type = type
        self.requiresApproval = requiresApproval
        self.maxParticipants = maxParticipants
        self.channelName = channelName
        self.ownerId = ownerId
        self.memberCount = memberCount
    }


    public var canStart: Bool { status == .scheduled }

    public var canCancel: Bool { status == .scheduled }

    public var canEnd: Bool { status == .ongoing }

    public var canUpdate: Bool { status == .scheduled }

    public var canRequestToken: Bool { status == .ongoing }

    public var isFull: Bool { memberCount >= maxParticipants }
}
