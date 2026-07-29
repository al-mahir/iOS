//
//  CircleEndedSocketEventDTO.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct CircleEndedSocketEventDTO: Codable, Sendable {
    public let circleId: String?
    public let reason: String?

    public init(circleId: String? = nil, reason: String? = nil) {
        self.circleId = circleId
        self.reason = reason
    }
}
