//
//  PaymobTransactionDTO.swift
//  Payment — Transaction Status Polling
//
//  GET https://accept.paymob.com/api/acceptance/transactions/<id>
//  Used to poll whether the user has confirmed the wallet OTP.
//

import Foundation

// MARK: - Transaction Status Response

struct PaymobTransactionStatusDTO: Decodable {
    let id: Int
    let pending: Bool
    let success: Bool
    let is_voided: Bool?
    let is_refunded: Bool?
    let error_occured: Bool?
    let amount_cents: Int?
    let currency: String?
    let created_at: String?

    struct SourceData: Decodable {
        let pan: String?
        let type: String?
        let sub_type: String?
    }
    let source_data: SourceData?

    struct OrderInfo: Decodable {
        let id: Int?
        let merchant_order_id: String?
    }
    let order: OrderInfo?

    // MARK: Computed

    var isApproved: Bool { success && !pending }
    var isDeclined: Bool { (error_occured == true) || (is_voided == true) }
    var isStillPending: Bool { pending && !success }
}
