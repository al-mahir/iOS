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

// MARK: - Static Sample Packages

public extension SheikhPackage {
    static let staticBasic = SheikhPackage(
        id: "pkg-basic",
        nameEn: "Basic Plan",
        nameAr: "الباقة الأساسية",
        daysPerWeek: "2 Days / Week",
        pricePerMonth: 150,
        pricePerSession: "EGP 18.75 / session",
        features: [
            "8 Sessions / Month",
            "30 mins per session",
            "Tajweed Correction",
            "Flexible Rescheduling"
        ],
        isRecommended: false
    )

    static let staticStandard = SheikhPackage(
        id: "pkg-standard",
        nameEn: "Standard Plan",
        nameAr: "الباقة القياسية",
        daysPerWeek: "3 Days / Week",
        pricePerMonth: 200,
        pricePerSession: "EGP 16.66 / session",
        features: [
            "12 Sessions / Month",
            "45 mins per session",
            "Tajweed & Hifz Revision",
            "Direct Sheikh Chat",
            "Monthly Progress Report"
        ],
        isRecommended: true
    )

    static let staticPremium = SheikhPackage(
        id: "pkg-premium",
        nameEn: "Premium Plan",
        nameAr: "الباقة الممتازة",
        daysPerWeek: "5 Days / Week",
        pricePerMonth: 350,
        pricePerSession: "EGP 17.50 / session",
        features: [
            "20 Sessions / Month",
            "60 mins per session",
            "Ijazah Track & Certification",
            "Priority Scheduling",
            "1-on-1 Dedicated Support"
        ],
        isRecommended: false
    )

    static let staticPackages: [SheikhPackage] = [
        staticBasic,
        staticStandard,
        staticPremium
    ]
}

