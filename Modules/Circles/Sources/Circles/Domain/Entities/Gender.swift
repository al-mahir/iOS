//
//  Gender.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

import Foundation

public enum Gender: String, CaseIterable, Sendable {
    case male = "Male"
    case female = "Female"

    public var displayTitle: String { rawValue }
}
