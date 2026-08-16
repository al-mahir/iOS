//
//  CardPaymentResult.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation

private final class PaymentBundleToken {}

public struct CardPaymentResult: Sendable {
    public let transactionID: String
    public let amount: Decimal
    public let cardProvider: CardProvider
    public let packageTitle: String
    public let timestamp: Date
    public let maskedCardNumber: String
    public let last4: String
    
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
        cardProvider: CardProvider,
        packageTitle: String,
        timestamp: Date,
        maskedCardNumber: String,
        last4: String
    ) {
        self.transactionID = transactionID
        self.amount = amount
        self.cardProvider = cardProvider
        self.packageTitle = packageTitle
        self.timestamp = timestamp
        self.maskedCardNumber = maskedCardNumber
        self.last4 = last4
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

// MARK: - CardPaymentError

/// Errors that can be thrown during a card payment operation.
public enum CardPaymentError: LocalizedError {
    case invalidCardNumber
    case invalidExpiryDate
    case invalidCVV
    case invalidHolderName
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
        case .invalidCardNumber:
            return NSLocalizedString(
                "card_error_invalid_number",
                bundle: Self.bundle,
                value: "Please enter a valid card number.",
                comment: "Validation error for invalid card number"
            )
        case .invalidExpiryDate:
            return NSLocalizedString(
                "card_error_invalid_expiry",
                bundle: Self.bundle,
                value: "Please enter a valid expiry date.",
                comment: "Validation error for invalid expiry date"
            )
        case .invalidCVV:
            return NSLocalizedString(
                "card_error_invalid_cvv",
                bundle: Self.bundle,
                value: "Please enter a valid CVV (3 or 4 digits).",
                comment: "Validation error for invalid CVV"
            )
        case .invalidHolderName:
            return NSLocalizedString(
                "card_error_invalid_holder_name",
                bundle: Self.bundle,
                value: "Please enter the cardholder's name.",
                comment: "Validation error for invalid cardholder name"
            )
        case .networkFailure(let msg):
            let format = NSLocalizedString(
                "card_error_network_failure_format",
                bundle: Self.bundle,
                value: "Network error: %@",
                comment: "Error description format for card network failures"
            )
            return String(format: format, msg)
        case .transactionDeclined(let msg):
            let format = NSLocalizedString(
                "card_error_transaction_declined_format",
                bundle: Self.bundle,
                value: "Transaction declined: %@",
                comment: "Error description format for declined card transactions"
            )
            return String(format: format, msg)
        case .simulatedFailure:
            return NSLocalizedString(
                "card_error_simulated_failure",
                bundle: Self.bundle,
                value: "Payment simulation failed. Try a different card.",
                comment: "Error description for simulated card payment failure"
            )
        }
    }
}
