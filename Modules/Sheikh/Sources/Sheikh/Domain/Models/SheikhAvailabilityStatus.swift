//
//  SheikhAvailabilityStatus.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public enum SheikhAvailabilityStatus: String, Sendable, Codable, Equatable {
    case available = "AVAILABLE"
    case notAvailable = "NOT_AVAILABLE"
    case pendingApproval = "PENDING_APPROVAL"

    public var displayTitle: String {
        switch self {
        case .available: return "Available Now"
        case .notAvailable: return "In Session"
        case .pendingApproval: return "Pending approval"
        }
    }
}
