//
//  CircleType.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public enum CircleType: String, Codable, Hashable, Sendable, CaseIterable {
    case `public` = "PUBLIC"
    case `private` = "PRIVATE"

    public var displayTitle: String {
        switch self {
        case .public: return "Public"
        case .private: return "Private"
        }
    }
}
