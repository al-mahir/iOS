//
//  SubscriptionPackage.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation

private final class PaymentBundleToken {}

public struct SubscriptionPackage: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let priceEGP: Decimal
    public let durationMonths: Int
    public let reciterName: String
    public let features: [String]

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    public init(
        id: String,
        title: String,
        subtitle: String,
        priceEGP: Decimal,
        durationMonths: Int,
        reciterName: String,
        features: [String]
    ) {
        self.id            = id
        self.title         = title
        self.subtitle      = subtitle
        self.priceEGP      = priceEGP
        self.durationMonths = durationMonths
        self.reciterName   = reciterName
        self.features      = features
    }

    // MARK: Formatted helpers

    /// e.g. "79.99 EGP"
    public var formattedPrice: String {
        let ns = NSDecimalNumber(decimal: priceEGP)
        let format = NSLocalizedString(
            "formatted_amount_egp_format",
            bundle: Self.bundle,
            value: "%.2f EGP",
            comment: "Formatted price string with currency code"
        )
        return String(format: format, ns.doubleValue)
    }

    /// e.g. "3 Months"
    public var formattedDuration: String {
        if durationMonths == 1 {
            return NSLocalizedString(
                "duration_one_month",
                bundle: Self.bundle,
                value: "1 Month",
                comment: "Single month duration string"
            )
        } else {
            let format = NSLocalizedString(
                "duration_months_format",
                bundle: Self.bundle,
                value: "%d Months",
                comment: "Plural duration format string in months"
            )
            return String(format: format, durationMonths)
        }
    }
}

// MARK: - Mock Factory

public extension SubscriptionPackage {
    /// Convenience mock packages for testing and previews.
    static let mockBasic = SubscriptionPackage(
        id: "pkg_basic",
        title: "Basic Reciter Pass",
        subtitle: "Unlock one reciter for 1 month",
        priceEGP: 39.99,
        durationMonths: 1,
        reciterName: "Sheikh Maher Al-Muaiqly",
        features: [
            "Full Quran recitation",
            "Offline downloads",
            "High-quality audio"
        ]
    )

    static let mockPremium = SubscriptionPackage(
        id: "pkg_premium",
        title: "Premium Reciter Pass",
        subtitle: "Unlock one reciter for 3 months",
        priceEGP: 99.99,
        durationMonths: 3,
        reciterName: "Sheikh Abdul Rahman Al-Sudais",
        features: [
            "Full Quran recitation",
            "Offline downloads",
            "High-quality audio",
            "Exclusive Tafsir sessions",
            "Priority customer support"
        ]
    )

    static let mockAnnual = SubscriptionPackage(
        id: "pkg_annual",
        title: "Annual Reciter Pass",
        subtitle: "Unlock one reciter for 12 months",
        priceEGP: 299.99,
        durationMonths: 12,
        reciterName: "Sheikh Mishary Rashid Alafasy",
        features: [
            "Full Quran recitation",
            "Offline downloads",
            "High-quality audio",
            "Exclusive Tafsir sessions",
            "Priority customer support",
            "Early access to new reciters"
        ]
    )
}
