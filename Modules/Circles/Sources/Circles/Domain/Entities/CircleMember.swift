//
//  CircleMember.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public struct CircleMember: Equatable, Hashable, Sendable {

    public let id: String
    public let username: String
    public let status: CircleMembershipStatus
    public let joinedAt: Date

    public init(
        id: String,
        username: String,
        status: CircleMembershipStatus,
        joinedAt: Date
    ) {
        self.id = id
        self.username = username
        self.status = status
        self.joinedAt = joinedAt
    }
}
