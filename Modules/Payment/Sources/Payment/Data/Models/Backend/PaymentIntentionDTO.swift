//
//  PaymentIntentionDTO.swift
//  Payment
//
//  Created by Al-Mahir.
//

import Foundation

public struct PaymentIntentionDTO: Decodable, Sendable {
    public let intentionId: String
    public let clientSecret: String
    public let publicKey: String
    public let amountMinorUnits: Int64?
    public let currencyCode: String?
    public let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case intentionId, clientSecret, publicKey, amountMinorUnits, currencyCode, expiresAt
    }
}

public struct PaymentIntentionStatusDTO: Decodable, Sendable {
    public let status: String
    public let transactionId: String?
    public let failureReasonCode: String?

    public init(status: String, transactionId: String? = nil, failureReasonCode: String? = nil) {
        self.status = status
        self.transactionId = transactionId
        self.failureReasonCode = failureReasonCode
    }
}
