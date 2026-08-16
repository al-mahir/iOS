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
}
