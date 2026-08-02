//
//  PaymentRepositoryProtocol.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

public protocol WalletPaymentRepositoryProtocol: Sendable {

    func processWalletPayment(
        package: SubscriptionPackage,
        provider: WalletProvider,
        phoneNumber: String
    ) async throws -> PaymentResult
}
