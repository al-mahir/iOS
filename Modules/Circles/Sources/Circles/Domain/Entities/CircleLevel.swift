//
//  CircleLevel.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public enum CircleLevel: String, Codable, CaseIterable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    public var title: String {
        rawValue
    }
}
