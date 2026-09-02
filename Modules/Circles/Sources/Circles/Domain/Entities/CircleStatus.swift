//
//  CircleStatus.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public enum CircleStatus: String, Codable, Hashable, Sendable {
    case scheduled = "SCHEDULED"
    case ongoing = "ONGOING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    public init(fromRaw string: String) {
        let upper = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch upper {
        case "SCHEDULED":
            self = .scheduled
        case "ONGOING", "LIVE", "ACTIVE":
            self = .ongoing
        case "COMPLETED", "FINISHED", "ENDED", "DONE":
            self = .completed
        case "CANCELLED", "CANCELED":
            self = .cancelled
        default:
            self = CircleStatus(rawValue: upper) ?? .scheduled
        }
    }
}
