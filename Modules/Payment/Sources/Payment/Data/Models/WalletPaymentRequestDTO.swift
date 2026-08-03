//
//  WalletPaymentRequestDTO.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

// MARK: - PaymentRequestDTO

/// Network payload sent to the Paymob wallet endpoint.
struct WalletPaymentRequestDTO: Encodable {
    /// The subscription package identifier.
    let packageID: String
    /// Wallet provider raw value (e.g. "vodafone_cash").
    let walletProvider: String
    /// The user's full mobile wallet number.
    let phoneNumber: String
    /// Amount in the currency specified below.
    let amount: Double
    /// ISO 4217 currency code.
    let currency: String

    enum CodingKeys: String, CodingKey {
        case packageID       = "package_id"
        case walletProvider  = "wallet_provider"
        case phoneNumber     = "phone_number"
        case amount
        case currency
    }
}
