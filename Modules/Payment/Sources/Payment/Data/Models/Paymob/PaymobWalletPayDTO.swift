//
//  PaymobWalletPayDTO.swift
//  Payment — Step 4: Wallet Payment Initiation
//
//  POST https://accept.paymob.com/api/acceptance/payments/pay
//  No auth header needed — the payment_token carries authentication.
//
//  After this call, Paymob sends an OTP SMS to the user's wallet phone number.
//  The user confirms in their wallet app (Vodafone Cash, Orange Cash, etc.).
//

import Foundation

// MARK: - Wallet Source

struct PaymobWalletSourceDTO: Encodable {
    /// The user's mobile wallet phone number.
    let identifier: String
    /// Always "WALLET" for mobile wallet payments.
    let subtype: String

    init(phoneNumber: String) {
        // Paymob requires +country-code format
        self.identifier = phoneNumber.hasPrefix("+") ? phoneNumber : "+2\(phoneNumber)"
        self.subtype    = "WALLET"
    }
}

// MARK: - Request

struct PaymobWalletPayRequestDTO: Encodable {
    let source: PaymobWalletSourceDTO
    /// The payment_key token from Step 3.
    let payment_token: String
}

// MARK: - Response

struct PaymobWalletPayResponseDTO: Decodable {
    /// Paymob's numeric transaction ID.
    let id: Int
    /// true = OTP sent, payment pending user confirmation.
    let pending: Bool
    /// false initially; becomes true after user confirms OTP in wallet app.
    let success: Bool
    /// "PENDING", "DECLINED", "APPROVED"
    let is_voided: Bool?
    let is_refunded: Bool?
    /// Optional URL — some wallet flows redirect here for OTP entry.
    let redirect_url: String?

    // MARK: Nested

    struct SourceData: Decodable {
        let pan: String?       // Masked phone number
        let type: String?
        let sub_type: String?
    }
    let source_data: SourceData?

    struct OrderInfo: Decodable {
        let id: Int
        let merchant_order_id: String?
    }
    let order: OrderInfo?
}
