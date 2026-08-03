//
//  PaymentResult.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

public struct PaymentResult: Sendable {
    public let transactionID: String
    public let amount: Decimal
    public let walletProvider: WalletProvider
    public let packageTitle: String
    public let timestamp: Date
    /// Last 4 digits visible, rest masked — e.g. "010*****1234"
    public let maskedPhoneNumber: String

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
        return String(format: "%.2f EGP", ns.doubleValue)
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

    public var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return "Please enter a valid 11-digit Egyptian mobile number."
        case .networkFailure(let msg):
            return "Network error: \(msg)"
        case .transactionDeclined(let msg):
            return "Transaction declined: \(msg)"
        case .simulatedFailure:
            return "Payment simulation failed. Try a different number."
        }
    }
}
