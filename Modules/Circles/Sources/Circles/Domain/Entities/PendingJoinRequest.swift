//
//  PendingJoinRequest.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public struct PendingJoinRequest: Equatable, Hashable, Sendable {

    public let userId: String
    public let username: String
    public let requestedAt: Date

    public init(userId: String, username: String, requestedAt: Date) {
        self.userId = userId
        self.username = username
        self.requestedAt = requestedAt
    }
}
