//
//  WalletPaymentRepositoryImpl.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

final class WalletPaymentRepositoryImpl: WalletPaymentRepositoryProtocol, Sendable {



    private let dataSource: WalletDataSourceProtocol
    private let mapper: WalletPaymentMapper



    init(dataSource: WalletDataSourceProtocol, mapper: WalletPaymentMapper = WalletPaymentMapper()) {
        self.dataSource = dataSource
        self.mapper = mapper
    }


    func processWalletPayment(
        package: SubscriptionPackage,
        provider: WalletProvider,
        phoneNumber: String
    ) async throws -> PaymentResult {

        // 1. Map domain entities → request DTO
        let requestDTO = mapper.toRequestDTO(
            package: package,
            provider: provider,
            phoneNumber: phoneNumber
        )

        // 2. Call data source (mock or real Paymob network)
        let responseDTO = try await dataSource.processPayment(requestDTO)

        // 3. Handle Paymob's "pending" status (OTP sent, awaiting user confirmation).
        //    We signal this to the ViewModel by prefixing the transaction ID with "PENDING-".
        //    The ViewModel will then switch to .awaitingConfirmation state.
        if responseDTO.status == "pending" {
            return PaymentResult(
                transactionID: "PENDING-\(responseDTO.transactionID)",
                amount: Decimal(responseDTO.amount),
                walletProvider: provider,
                packageTitle: responseDTO.packageTitle,
                timestamp: Date(),
                maskedPhoneNumber: maskPhone(phoneNumber)
            )
        }

        // 4. Map response DTO → domain entity (success path)
        return try mapper.toDomain(dto: responseDTO, provider: provider)
    }

    // MARK: Helpers

    private func maskPhone(_ number: String) -> String {
        let digits = number.filter(\.isNumber)
        guard digits.count >= 7 else { return number }
        let prefix = String(digits.prefix(3))
        let suffix = String(digits.suffix(3))
        let mask = String(repeating: "*", count: digits.count - 6)
        return "\(prefix)\(mask)\(suffix)"
    }
}
