//
//  WalletDatasourceProtocol.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


protocol WalletDataSourceProtocol: Sendable {
    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO
}
