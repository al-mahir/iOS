//
//  PaymentIntentionDTO.swift
//  Payment
//
//  Created by Al-Mahir.
//

import Foundation

// MARK: - Intention Data DTO

public struct PaymentIntentionDataDTO: Decodable, Sendable {
    public let id: String?
    public let intentionId: String?
    public let clientSecret: String?
    public let client_secret: String?
    public let publicKey: String?
    public let public_key: String?
    public let status: String?
    public let paymentKey: String?
    public let payment_key: String?

    enum CodingKeys: String, CodingKey {
        case id
        case intentionId
        case intention_id
        case clientSecret
        case client_secret
        case publicKey
        case public_key
        case status
        case paymentKey
        case payment_key
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? container.decodeIfPresent(String.self, forKey: .intention_id)
        self.intentionId = try container.decodeIfPresent(String.self, forKey: .intentionId) ?? self.id
        self.clientSecret = try container.decodeIfPresent(String.self, forKey: .clientSecret) ?? container.decodeIfPresent(String.self, forKey: .client_secret)
        self.client_secret = self.clientSecret
        self.publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey) ?? container.decodeIfPresent(String.self, forKey: .public_key)
        self.public_key = self.publicKey
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.paymentKey = try container.decodeIfPresent(String.self, forKey: .paymentKey) ?? container.decodeIfPresent(String.self, forKey: .payment_key)
        self.payment_key = self.paymentKey
    }

    public var effectiveClientSecret: String? {
        clientSecret ?? client_secret ?? paymentKey ?? payment_key
    }

    public var effectivePublicKey: String? {
        publicKey ?? public_key
    }

    public var effectiveID: String {
        id ?? intentionId ?? "INT-\(UUID().uuidString.prefix(8))"
    }
}

// MARK: - Intention Status DTO

public struct PaymentIntentionStatusDTO: Decodable, Sendable {
    public let id: String?
    public let status: String?
    public let isSuccess: Bool?
    public let is_success: Bool?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case isSuccess
        case is_success
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.isSuccess = try container.decodeIfPresent(Bool.self, forKey: .isSuccess)
        self.is_success = try container.decodeIfPresent(Bool.self, forKey: .is_success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
    }

    public var isCompletedSuccessfully: Bool {
        if let isSuccess = isSuccess ?? is_success {
            return isSuccess
        }
        let stat = (status ?? "").lowercased()
        return stat == "success" || stat == "paid" || stat == "completed" || stat == "successful"
    }
}
