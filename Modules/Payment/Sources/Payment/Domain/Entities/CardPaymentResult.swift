//
//  CardPaymentResult.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation

public struct CardPaymentResult: Sendable {
    public let transactionID: String
    public let amount: Decimal
    public let cardProvider: CardProvider
    public let packageTitle: String
    public let timestamp: Date
    public let maskedCardNumber: String
    public let last4: String
    
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
        return String(format: "%.2f EGP", ns.doubleValue)
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

    public var errorDescription: String? {
        switch self {
        case .invalidCardNumber:
            return "Please enter a valid card number."
        case .invalidExpiryDate:
            return "Please enter a valid expiry date."
        case .invalidCVV:
            return "Please enter a valid CVV (3 or 4 digits)."
        case .invalidHolderName:
            return "Please enter the cardholder's name."
        case .networkFailure(let msg):
            return "Network error: \(msg)"
        case .transactionDeclined(let msg):
            return "Transaction declined: \(msg)"
        case .simulatedFailure:
            return "Payment simulation failed. Try a different card."
        }
    }
}
