//
//  SheikhPackage.swift
//  Sheikh
//

import Foundation

public struct SheikhPackage: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameAr: String
    public let daysPerWeek: String
    public let pricePerMonth: Int
    public let pricePerSession: String
    public let features: [String]
    public let isRecommended: Bool

    public init(
        id: String,
        nameEn: String,
        nameAr: String,
        daysPerWeek: String,
        pricePerMonth: Int,
        pricePerSession: String,
        features: [String],
        isRecommended: Bool = false
    ) {
        self.id = id
        self.nameEn = nameEn
        self.nameAr = nameAr
        self.daysPerWeek = daysPerWeek
        self.pricePerMonth = pricePerMonth
        self.pricePerSession = pricePerSession
        self.features = features
        self.isRecommended = isRecommended
    }

    public var titleFormatted: String {
        "\(nameEn) / \(nameAr)"
    }
}
