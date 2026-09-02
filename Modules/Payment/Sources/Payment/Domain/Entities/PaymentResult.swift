//
//  PaymentResult.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

private final class PaymentBundleToken {}

public struct PaymentResult: Sendable {
    public let transactionID: String
    public let amount: Decimal
    public let walletProvider: WalletProvider
    public let packageTitle: String
    public let timestamp: Date
    /// Last 4 digits visible, rest masked — e.g. "010*****1234"
    public let maskedPhoneNumber: String

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    public init(
        transactionID: String,
        amount: Decimal,
        walletProvider: WalletProvider,
        packageTitle: String,
        timestamp: Date,
        maskedPhoneNumber: String
    ) {
        self.transactionID     = transactionID
        self.amount            = amount
        self.walletProvider    = walletProvider
        self.packageTitle      = packageTitle
        self.timestamp         = timestamp
        self.maskedPhoneNumber = maskedPhoneNumber
    }

    // MARK: Formatted helpers

    public var formattedAmount: String {
        let ns = NSDecimalNumber(decimal: amount)
        let format = NSLocalizedString(
            "formatted_amount_egp_format",
            bundle: Self.bundle,
            value: "%.2f EGP",
            comment: "Formatted amount string with currency code"
        )
        return String(format: format, ns.doubleValue)
    }

    public var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .short
        return fmt.string(from: timestamp)
    }
}

// MARK: - PaymentError

/// Errors that can be thrown during a payment operation.
public enum PaymentError: LocalizedError {
    case invalidPhoneNumber
    case networkFailure(String)
    case transactionDeclined(String)
    case simulatedFailure

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    public var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return NSLocalizedString(
                "wallet_error_invalid_phone_number",
                bundle: Self.bundle,
                value: "Please enter a valid 11-digit Egyptian mobile number.",
                comment: "Validation error for invalid Egyptian phone number"
            )
        case .networkFailure(let msg):
            let format = NSLocalizedString(
                "wallet_error_network_failure_format",
                bundle: Self.bundle,
                value: "Network error: %@",
                comment: "Error description format for wallet network failures"
            )
            return String(format: format, msg)
        case .transactionDeclined(let msg):
            let format = NSLocalizedString(
                "wallet_error_transaction_declined_format",
                bundle: Self.bundle,
                value: "Transaction declined: %@",
                comment: "Error description format for declined wallet transactions"
            )
            return String(format: format, msg)
        case .simulatedFailure:
            return NSLocalizedString(
                "wallet_error_simulated_failure",
                bundle: Self.bundle,
                value: "Payment simulation failed. Try a different number.",
                comment: "Error description for simulated wallet payment failure"
            )
        }
    }
}
