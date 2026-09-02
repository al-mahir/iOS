//
//  PaymentMethod.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI

private final class PaymentBundleToken {}

public enum PaymentMethod: String, CaseIterable, Identifiable, Sendable {
    case wallet = "wallet"
    case card = "card"
    
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
        case .wallet:
            return NSLocalizedString(
                "payment_method_wallet_title",
                bundle: Self.bundle,
                value: "Mobile Wallet",
                comment: "Display name for mobile wallet payment method"
            )
        case .card:
            return NSLocalizedString(
                "payment_method_card_title",
                bundle: Self.bundle,
                value: "Credit/Debit Card",
                comment: "Display name for card payment method"
            )
        }
    }
    
    public var icon: String {
        switch self {
        case .wallet: return "wallet.pass.fill"
        case .card: return "creditcard.fill"
        }
    }
}
