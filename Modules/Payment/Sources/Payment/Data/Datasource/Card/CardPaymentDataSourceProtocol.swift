//
//  CardPaymentDataSourceProtocol.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

protocol CardPaymentDataSourceProtocol: Sendable {
    func processPayment(_ request: CardPaymentRequestDTO) async throws -> CardPaymentResponseDTO
    func checkStatus(intentionId: String) async throws -> PaymentIntentionStatusDTO
}
