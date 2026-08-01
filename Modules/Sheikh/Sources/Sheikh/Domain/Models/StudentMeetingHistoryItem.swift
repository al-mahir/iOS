//
//  StudentMeetingHistoryItem.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct StudentMeetingHistoryItem: Sendable, Equatable, Identifiable {
    public var id: String { requestId }
    public let requestId: String
    public let sheikhId: String
    public let sheikhName: String
    public let status: InstantMeetingStatus
    public let requestedAt: Date?
    public let acceptedAt: Date?
    public let endedAt: Date?

    public init(
        requestId: String,
        sheikhId: String,
        sheikhName: String,
        status: InstantMeetingStatus,
        requestedAt: Date? = nil,
        acceptedAt: Date? = nil,
        endedAt: Date? = nil
    ) {
        self.requestId = requestId
        self.sheikhId = sheikhId
        self.sheikhName = sheikhName
        self.status = status
        self.requestedAt = requestedAt
        self.acceptedAt = acceptedAt
        self.endedAt = endedAt
    }
}
