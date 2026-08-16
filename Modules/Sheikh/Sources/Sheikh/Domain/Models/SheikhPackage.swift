//
//  SheikhPackage.swift
//  Sheikh
//

import Foundation

public struct SheikhPackage: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameAr: String
    public let daysPerWeekEn: String
    public let daysPerWeekAr: String
    public let pricePerMonth: Int
    public let pricePerSessionEn: String
    public let pricePerSessionAr: String
    public let featuresEn: [String]
    public let featuresAr: [String]
    public let isRecommended: Bool

    public init(
        id: String,
        nameEn: String,
        nameAr: String,
        daysPerWeekEn: String,
        daysPerWeekAr: String,
        pricePerMonth: Int,
        pricePerSessionEn: String,
        pricePerSessionAr: String,
        featuresEn: [String],
        featuresAr: [String],
        isRecommended: Bool = false
    ) {
        self.id = id
        self.nameEn = nameEn
        self.nameAr = nameAr
        self.daysPerWeekEn = daysPerWeekEn
        self.daysPerWeekAr = daysPerWeekAr
        self.pricePerMonth = pricePerMonth
        self.pricePerSessionEn = pricePerSessionEn
        self.pricePerSessionAr = pricePerSessionAr
        self.featuresEn = featuresEn
        self.featuresAr = featuresAr
        self.isRecommended = isRecommended
    }

    // MARK: - Safe Localized Getters

    public func name(isArabic: Bool) -> String {
        isArabic ? nameAr : nameEn
    }

    public func daysPerWeek(isArabic: Bool) -> String {
        isArabic ? daysPerWeekAr : daysPerWeekEn
    }

    public func pricePerSession(isArabic: Bool) -> String {
        isArabic ? pricePerSessionAr : pricePerSessionEn
    }

    public func features(isArabic: Bool) -> [String] {
        isArabic ? featuresAr : featuresEn
    }

    public func titleFormatted(isArabic: Bool) -> String {
        isArabic ? "\(nameAr) / \(nameEn)" : "\(nameEn) / \(nameAr)"
    }
}

// MARK: - Static Sample Packages

public extension SheikhPackage {
    static let staticBasic = SheikhPackage(
        id: "pkg-basic",
        nameEn: "Basic Plan",
        nameAr: "الباقة الأساسية",
        daysPerWeekEn: "2 Days / Week",
        daysPerWeekAr: "يومان / أسبوعياً",
        pricePerMonth: 150,
        pricePerSessionEn: "EGP 18.75 / session",
        pricePerSessionAr: "18.75 ج.م / جلسة",
        featuresEn: [
            "8 Sessions / Month",
            "30 mins per session",
            "Tajweed Correction",
            "Flexible Rescheduling"
        ],
        featuresAr: [
            "8 جلسات / شهرياً",
            "30 دقيقة لكل جلسة",
            "تصحيح التجويد",
            "إعادة جدولة مرنة"
        ],
        isRecommended: false
    )

    static let staticStandard = SheikhPackage(
        id: "pkg-standard",
        nameEn: "Standard Plan",
        nameAr: "الباقة القياسية",
        daysPerWeekEn: "3 Days / Week",
        daysPerWeekAr: "3 أيام / أسبوعياً",
        pricePerMonth: 200,
        pricePerSessionEn: "EGP 16.66 / session",
        pricePerSessionAr: "16.66 ج.م / جلسة",
        featuresEn: [
            "12 Sessions / Month",
            "45 mins per session",
            "Tajweed & Hifz Revision",
            "Direct Sheikh Chat",
            "Monthly Progress Report"
        ],
        featuresAr: [
            "12 جلسة / شهرياً",
            "45 دقيقة لكل جلسة",
            "مراجعة التجويد والحفظ",
            "محادثة مباشرة مع الشيخ",
            "تقرير التقدم الشهري"
        ],
        isRecommended: true
    )

    static let staticPremium = SheikhPackage(
        id: "pkg-premium",
        nameEn: "Premium Plan",
        nameAr: "الباقة الممتازة",
        daysPerWeekEn: "5 Days / Week",
        daysPerWeekAr: "5 أيام / أسبوعياً",
        pricePerMonth: 350,
        pricePerSessionEn: "EGP 17.50 / session",
        pricePerSessionAr: "17.50 ج.م / جلسة",
        featuresEn: [
            "20 Sessions / Month",
            "60 mins per session",
            "Ijazah Track & Certification",
            "Priority Scheduling",
            "1-on-1 Dedicated Support"
        ],
        featuresAr: [
            "20 جلسة / شهرياً",
            "60 دقيقة لكل جلسة",
            "مسار الإجازة والشهادة",
            "جدولة ذات أولوية",
            "دعم مخصص 1 لـ 1"
        ],
        isRecommended: false
    )

    static let staticPackages: [SheikhPackage] = [
        staticBasic,
        staticStandard,
        staticPremium
    ]
}
