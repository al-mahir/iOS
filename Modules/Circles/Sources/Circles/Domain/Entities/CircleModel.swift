//
//  Circle.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public struct CircleModel: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let topic: String
    public let sheikhName: String
    public let sheikhInitials: String
    public let level: CircleLevel
    public let visibility: CircleVisibility
    public let isLive: Bool
    public let currentParticipants: Int
    public let maxParticipants: Int
    public let requiresApproval: Bool

    public var capacityText: String {
        "\(currentParticipants)/\(maxParticipants)"
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        topic: String,
        sheikhName: String,
        sheikhInitials: String,
        level: CircleLevel = .intermediate,
        visibility: CircleVisibility = .publicCircle,
        isLive: Bool = true,
        currentParticipants: Int = 1,
        maxParticipants: Int = 10,
        requiresApproval: Bool = true
    ) {
        self.id = id
        self.name = name
        self.topic = topic
        self.sheikhName = sheikhName
        self.sheikhInitials = sheikhInitials
        self.level = level
        self.visibility = visibility
        self.isLive = isLive
        self.currentParticipants = currentParticipants
        self.maxParticipants = maxParticipants
        self.requiresApproval = requiresApproval
    }
}
