//
//  PaymobPaymentKeyDTO.swift
//  Payment — Step 3: Payment Key
//
//  POST https://accept.paymob.com/api/acceptance/payment_keys
//  Headers: Authorization: Bearer <auth_token>
//  Returns: { "token": "<payment_key>" }
//

import Foundation

// MARK: - Billing Data

/// Minimum required billing data for Paymob payment key.
struct PaymobBillingDataDTO: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let phone_number: String
    let city: String
    let country: String
    let street: String
    let building: String
    let floor: String
    let apartment: String
    let shipping_method: String
    let postal_code: String
    let state: String

    /// Convenience init with sensible guest defaults for wallet-only flows.
    init(phone: String, firstName: String = "Al-Mahir", lastName: String = "User") {
        self.first_name      = firstName
        self.last_name       = lastName
        self.email           = "user@almahir.app"
        // Paymob requires +country-code prefix
        self.phone_number    = phone.hasPrefix("+") ? phone : "+2\(phone)"
        self.city            = "Cairo"
        self.country         = "EG"
        self.street          = "N/A"
        self.building        = "N/A"
        self.floor           = "N/A"
        self.apartment       = "N/A"
        self.shipping_method = "N/A"
        self.postal_code     = "N/A"
        self.state           = "N/A"
    }
}

// MARK: - Request

struct PaymobPaymentKeyRequestDTO: Encodable {
    let auth_token: String
    let amount_cents: Int
    let expiration: Int       // Seconds until key expires (e.g. 3600)
    let order_id: Int
    let billing_data: PaymobBillingDataDTO
    let currency: String
    let integration_id: Int
    let lock_order_when_paid: String

    init(
        authToken: String,
        amountCents: Int,
        orderID: Int,
        integrationID: Int,
        phone: String,
        currency: String = "EGP"
    ) {
        self.auth_token           = authToken
        self.amount_cents         = amountCents
        self.expiration           = 3600
        self.order_id             = orderID
        self.billing_data         = PaymobBillingDataDTO(phone: phone)
        self.currency             = currency
        self.integration_id       = integrationID
        self.lock_order_when_paid = "false"
    }
}

// MARK: - Response

struct PaymobPaymentKeyResponseDTO: Decodable {
    /// The short-lived payment token to use in the wallet pay call.
    let token: String
}
