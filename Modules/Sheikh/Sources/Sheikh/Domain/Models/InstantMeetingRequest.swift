//
//  InstantMeetingRequest.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct InstantMeetingRequest: Sendable, Equatable {
    public let requestId: String
    public let status: InstantMeetingStatus
    public let channelName: String?
    public let expiresAt: Date?

    public init(
        requestId: String,
        status: InstantMeetingStatus,
        channelName: String? = nil,
        expiresAt: Date? = nil
    ) {
        self.requestId = requestId
        self.status = status
        self.channelName = channelName
        self.expiresAt = expiresAt
    }
}
