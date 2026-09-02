//
//  WalletPaymentResponseDTO.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Foundation

// MARK: - PaymentResponseDTO

/// Network response from the Paymob wallet endpoint.
struct WalletPaymentResponseDTO: Decodable {
    /// Unique transaction identifier returned by Paymob.
    let transactionID: String
    /// "success" or "failed".
    let status: String
    /// Amount charged.
    let amount: Double
    /// Wallet provider raw value.
    let walletProvider: String
    /// The wallet phone number used.
    let phoneNumber: String
    /// Package title for reference.
    let packageTitle: String
    /// ISO 8601 timestamp string.
    let timestamp: String
    /// Human-readable result message.
    let message: String

    enum CodingKeys: String, CodingKey {
        case transactionID  = "transaction_id"
        case status
        case amount
        case walletProvider = "wallet_provider"
        case phoneNumber    = "phone_number"
        case packageTitle   = "package_title"
        case timestamp
        case message
    }
}
