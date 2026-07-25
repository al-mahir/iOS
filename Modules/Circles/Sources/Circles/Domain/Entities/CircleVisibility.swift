//
//  CircleVisibility.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public enum CircleVisibility: String, Codable, CaseIterable, Sendable {
    case publicCircle = "Public"
    case privateCircle = "Private"

    public var title: String {
        rawValue
    }

    public var helperText: String {
        switch self {
        case .publicCircle:
            return "Visible in active circles search"
        case .privateCircle:
            return "Hidden from active circles search"
        }
    }
}
