//
//  PaymobOrderDTO.swift
//  Payment — Step 2: Order Registration
//
//  POST https://accept.paymob.com/api/ecommerce/orders
//  Headers: Authorization: Bearer <auth_token>
//  Body:  { amount_cents, currency, merchant_order_id, items, ... }
//  Returns: { "id": <order_id>, ... }
//

import Foundation

// MARK: - Item DTO

struct PaymobOrderItemDTO: Encodable {
    let name: String
    let amount_cents: Int
    let description: String
    let quantity: Int
}

// MARK: - Request

struct PaymobOrderRequestDTO: Encodable {
    let auth_token: String
    /// Amount in the smallest currency unit (e.g. 9999 = 99.99 EGP).
    let amount_cents: Int
    let currency: String
    let merchant_order_id: String
    let items: [PaymobOrderItemDTO]
    /// Must be false for digital service.
    let delivery_needed: Bool

    init(
        authToken: String,
        amountCents: Int,
        currency: String = "EGP",
        merchantOrderID: String,
        packageTitle: String
    ) {
        self.auth_token         = authToken
        self.amount_cents       = amountCents
        self.currency           = currency
        self.merchant_order_id  = merchantOrderID
        self.delivery_needed    = false
        self.items = [
            PaymobOrderItemDTO(
                name: packageTitle,
                amount_cents: amountCents,
                description: "Al-Mahir Reciter Subscription",
                quantity: 1
            )
        ]
    }
}

// MARK: - Response

struct PaymobOrderResponseDTO: Decodable {
    /// Paymob's numeric order ID used in the payment key request.
    let id: Int
    let merchant_order_id: String?
}
