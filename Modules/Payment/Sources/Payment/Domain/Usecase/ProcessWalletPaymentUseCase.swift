//
//  ProcessWalletPaymentUseCase.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation



public protocol ProcessWalletPaymentUseCase: Sendable {
    func execute(
        package: SubscriptionPackage,
        provider: WalletProvider,
        phoneNumber: String
    ) async throws -> PaymentResult
}

// MARK: - Implementation

/// Validates the phone number then delegates to the `PaymentRepositoryProtocol`.
///
/// **Validation rules (Egyptian mobile):**
/// - Must be exactly 11 digits
/// - Must start with 010, 011, 012, or 015
public final class ProcessWalletPaymentUseCaseImpl: ProcessWalletPaymentUseCase {

    // MARK: Init

    private let repository: WalletPaymentRepositoryProtocol

    public init(repository: WalletPaymentRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute

    public func execute(
        package: SubscriptionPackage,
        provider: WalletProvider,
        phoneNumber: String
    ) async throws -> PaymentResult {

   
        try validatePhoneNumber(phoneNumber)

        return try await repository.processWalletPayment(
            package: package,
            provider: provider,
            phoneNumber: phoneNumber
        )
    }

    // MARK: Validation

    private func validatePhoneNumber(_ number: String) throws {
        let digits = number.filter(\.isNumber)

        guard digits.count == 11 else {
            throw PaymentError.invalidPhoneNumber
        }

        let validPrefixes = ["010", "011", "012", "015"]
        let hasValidPrefix = validPrefixes.contains(where: { digits.hasPrefix($0) })

        guard hasValidPrefix else {
            throw PaymentError.invalidPhoneNumber
        }
    }
}
