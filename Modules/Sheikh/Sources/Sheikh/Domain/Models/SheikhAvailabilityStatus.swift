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
    case offline = "OFFLINE"
    case pendingApproval = "PENDING_APPROVAL"
    case declined = "DECLINED"
    case rejected = "REJECTED"

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = (try? container.decode(String.self)) ?? ""
        self = SheikhAvailabilityStatus(rawValue: rawString) ?? .offline
    }

    public var displayTitle: String {
        switch self {
        case .available: return "Available Now"
        case .notAvailable: return "In Session"
        case .offline, .declined, .rejected: return "Offline"
        case .pendingApproval: return "Pending approval"
        }
    }
}
