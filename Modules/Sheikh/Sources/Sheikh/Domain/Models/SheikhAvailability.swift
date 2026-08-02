//
//  SheikhAvailability.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct SheikhAvailability: Sendable, Equatable {
    public let sheikhId: String
    public let status: SheikhAvailabilityStatus
    public let updatedAt: Date?

    public init(sheikhId: String, status: SheikhAvailabilityStatus, updatedAt: Date? = nil) {
        self.sheikhId = sheikhId
        self.status = status
        self.updatedAt = updatedAt
    }
}
