//
//  JoinRequest.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public enum JoinRequestStatus: String, Codable, Sendable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
    case cancelled = "Cancelled"
}

public struct JoinRequest: Identifiable, Equatable, Sendable {
    public let id: String
    public let circleId: String
    public let circleName: String
    public let sheikhName: String
    public let status: JoinRequestStatus
    public let requestedAt: Date

    public init(
        id: String = UUID().uuidString,
        circleId: String,
        circleName: String,
        sheikhName: String,
        status: JoinRequestStatus = .pending,
        requestedAt: Date = Date()
    ) {
        self.id = id
        self.circleId = circleId
        self.circleName = circleName
        self.sheikhName = sheikhName
        self.status = status
        self.requestedAt = requestedAt
    }
}
