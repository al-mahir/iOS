//
//  CircleMembership.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public struct CircleMembership: Equatable, Hashable, Sendable {

    public let membershipId: String
    public let circleId: String
    public let userId: String
    public let status: CircleMembershipStatus
    public let requestedAt: Date

    public init(
        membershipId: String,
        circleId: String,
        userId: String,
        status: CircleMembershipStatus,
        requestedAt: Date
    ) {
        self.membershipId = membershipId
        self.circleId = circleId
        self.userId = userId
        self.status = status
        self.requestedAt = requestedAt
    }
}
