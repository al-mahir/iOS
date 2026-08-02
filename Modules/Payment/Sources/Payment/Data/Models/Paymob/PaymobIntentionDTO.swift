//
//  PaymobIntentionDTO.swift
//  Payment — New Paymob Intention API (v1)
//
//  POST https://accept.paymob.com/v1/intention/
//  Headers: Authorization: Token <secret_key>
//
//  This single endpoint replaces Steps 1-3 of the legacy API:
//  (auth/tokens + ecommerce/orders + acceptance/payment_keys)
//

import Foundation

// MARK: - Request

struct PaymobIntentionRequestDTO: Encodable {
    let amount: Int                    // Amount in cents (e.g. 4000 = 40.00 EGP)
    let currency: String
    let payment_methods: [Int]         // Array of integration IDs
    let items: [PaymobIntentionItemDTO]
    let billing_data: PaymobIntentionBillingDTO
    let special_reference: String      // Merchant order ID

    init(
        amountCents: Int,
        currency: String = "EGP",
        integrationID: Int,
        phone: String,
        merchantOrderID: String,
        packageTitle: String
    ) {
        self.amount = amountCents
        self.currency = currency
        self.payment_methods = [integrationID]
        self.special_reference = merchantOrderID
        self.items = [
            PaymobIntentionItemDTO(
                name: packageTitle,
                amount: amountCents,
                description: "Al-Mahir Reciter Subscription",
                quantity: 1
            )
        ]
        let phoneFormatted = phone.hasPrefix("+") ? phone : "+2\(phone)"
        self.billing_data = PaymobIntentionBillingDTO(
            first_name: "Al-Mahir",
            last_name: "User",
            email: "user@almahir.app",
            phone_number: phoneFormatted
        )
    }
}

struct PaymobIntentionItemDTO: Encodable {
    let name: String
    let amount: Int
    let description: String
    let quantity: Int
}

struct PaymobIntentionBillingDTO: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let phone_number: String
}

// MARK: - Response

struct PaymobIntentionResponseDTO: Decodable {
    let client_secret: String?

    struct PaymentKey: Decodable {
        let integration: Int?
        let key: String?
    }
    let payment_keys: [PaymentKey]?

    /// Extracts the payment key for the given integration ID (or the first available).
    func paymentKey(for integrationID: Int? = nil) -> String? {
        if let id = integrationID,
           let match = payment_keys?.first(where: { $0.integration == id }) {
            return match.key
        }
        return payment_keys?.first?.key
    }
}
