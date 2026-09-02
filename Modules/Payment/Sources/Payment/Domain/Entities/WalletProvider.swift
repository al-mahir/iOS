//
//  WalletProvider.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI

private final class PaymentBundleToken {}

public enum WalletProvider: String, CaseIterable, Identifiable, Sendable {
    case vodafoneCash = "vodafone_cash"
    case orangeCash   = "orange_cash"
    case eAndMoney    = "e_and_money"
    case wePay        = "we_pay"

    public var id: String { rawValue }

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    // MARK: Display

    public var displayName: String {
        switch self {
        case .vodafoneCash:
            return NSLocalizedString(
                "wallet_provider_vodafone_cash_title",
                bundle: Self.bundle,
                value: "Vodafone Cash",
                comment: "Display name for Vodafone Cash provider"
            )
        case .orangeCash:
            return NSLocalizedString(
                "wallet_provider_orange_cash_title",
                bundle: Self.bundle,
                value: "Orange Cash",
                comment: "Display name for Orange Cash provider"
            )
        case .eAndMoney:
            return NSLocalizedString(
                "wallet_provider_e_and_money_title",
                bundle: Self.bundle,
                value: "e& money",
                comment: "Display name for e& money provider"
            )
        case .wePay:
            return NSLocalizedString(
                "wallet_provider_we_pay_title",
                bundle: Self.bundle,
                value: "We Pay",
                comment: "Display name for We Pay provider"
            )
        }
    }

    public var tagline: String {
        switch self {
        case .vodafoneCash:
            return NSLocalizedString(
                "wallet_provider_vodafone_cash_tagline",
                bundle: Self.bundle,
                value: "Pay with your Vodafone wallet",
                comment: "Tagline for Vodafone Cash"
            )
        case .orangeCash:
            return NSLocalizedString(
                "wallet_provider_orange_cash_tagline",
                bundle: Self.bundle,
                value: "Pay with your Orange wallet",
                comment: "Tagline for Orange Cash"
            )
        case .eAndMoney:
            return NSLocalizedString(
                "wallet_provider_e_and_money_tagline",
                bundle: Self.bundle,
                value: "Pay with e& mobile money",
                comment: "Tagline for e& money"
            )
        case .wePay:
            return NSLocalizedString(
                "wallet_provider_we_pay_tagline",
                bundle: Self.bundle,
                value: "Pay with WE telecom wallet",
                comment: "Tagline for WE Pay"
            )
        }
    }

    // MARK: Brand Colors (hex)

    public var brandPrimaryHex: String {
        switch self {
        case .vodafoneCash: return "#E60026"
        case .orangeCash:   return "#FF6600"
        case .eAndMoney:    return "#000000"
        case .wePay:        return "#0072BC"
        }
    }

    public var brandSecondaryHex: String {
        switch self {
        case .vodafoneCash: return "#9B0019"
        case .orangeCash:   return "#CC5200"
        case .eAndMoney:    return "#3D3D3D"
        case .wePay:        return "#005291"
        }
    }

    // MARK: SF Symbol icon name

    public var symbolName: String {
        switch self {
        case .vodafoneCash: return "wave.3.right.circle.fill"
        case .orangeCash:   return "circle.hexagongrid.fill"
        case .eAndMoney:    return "e.circle.fill"
        case .wePay:        return "w.circle.fill"
        }
    }

    // MARK: Expected phone prefix(es)

    /// The dialing prefixes that match this provider (Egyptian mobile).
    public var expectedPrefixes: [String] {
        switch self {
        case .vodafoneCash: return ["010"]
        case .orangeCash:   return ["012"]
        case .eAndMoney:    return ["011"]
        case .wePay:        return ["015"]
        }
    }
}
