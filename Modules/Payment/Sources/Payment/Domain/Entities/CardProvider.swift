//
//  CardProvider.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI

private final class PaymentBundleToken {}

public enum CardProvider: String, CaseIterable, Identifiable, Sendable {
    case visa = "visa"
    case mastercard = "mastercard"
    
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
        case .visa:
            return NSLocalizedString(
                "card_provider_visa_title",
                bundle: Self.bundle,
                value: "Visa",
                comment: "Display name for Visa payment provider"
            )
        case .mastercard:
            return NSLocalizedString(
                "card_provider_mastercard_title",
                bundle: Self.bundle,
                value: "Mastercard",
                comment: "Display name for Mastercard payment provider"
            )
        }
    }
    
    public var tagline: String {
        switch self {
        case .visa:
            return NSLocalizedString(
                "card_provider_visa_tagline",
                bundle: Self.bundle,
                value: "Pay securely with Visa",
                comment: "Tagline for Visa payment option"
            )
        case .mastercard:
            return NSLocalizedString(
                "card_provider_mastercard_tagline",
                bundle: Self.bundle,
                value: "Pay securely with Mastercard",
                comment: "Tagline for Mastercard payment option"
            )
        }
    }
    
    // MARK: Brand Colors (hex)
    
    public var brandPrimaryHex: String {
        switch self {
        case .visa: return "#1A1F71"
        case .mastercard: return "#EB001B"
        }
    }
    
    public var brandSecondaryHex: String {
        switch self {
        case .visa: return "#F7B600"
        case .mastercard: return "#F79E1B"
        }
    }
    
    // MARK: SF Symbol icon name
    
    public var symbolName: String {
        switch self {
        case .visa: return "creditcard.fill"
        case .mastercard: return "creditcard.circle.fill"
        }
    }
}
