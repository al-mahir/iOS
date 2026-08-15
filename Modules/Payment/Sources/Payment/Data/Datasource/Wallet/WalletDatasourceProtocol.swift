//
//  WalletDataSourceProtocol.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

protocol WalletDataSourceProtocol: Sendable {
    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO
    func checkStatus(intentionId: String) async throws -> PaymentIntentionStatusDTO
}
