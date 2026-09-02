//
//  CardPaymentRepositoryProtocol.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation


public protocol CardPaymentRepositoryProtocol: Sendable {
    func processCardPayment(
        package: SubscriptionPackage,
        provider: CardProvider,
        cardNumber: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        holderName: String
    ) async throws -> CardPaymentResult
}
