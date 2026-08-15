//
//  RemoteWalletPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation
import NetworkKit
import Combine

/// Real backend payment intention data source for Mobile Wallet payments.
/// Hits `POST /api/payment/intentions` and `GET /api/payment/intentions/{id}/status`.
final class RemoteWalletPaymentDataSource: WalletDataSourceProtocol, Sendable {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO {
        let endpoint = PaymentEndpoints.createIntention(
            amount: request.amount,
            currency: "EGP",
            paymentMethod: request.walletProvider,
            phone: request.phoneNumber,
            packageTitle: "Al-Mahir Reciter Subscription"
        )

        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkService.request(endpoint)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: PaymentError.networkFailure(error.localizedDescription))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { (dto: PaymentIntentionDataDTO) in
                        let response = WalletPaymentResponseDTO(
                            transactionID: dto.effectiveID,
                            status: dto.status ?? "pending",
                            amount: request.amount,
                            walletProvider: request.walletProvider,
                            phoneNumber: request.phoneNumber,
                            packageTitle: "Al-Mahir Reciter Subscription",
                            timestamp: ISO8601DateFormatter().string(from: Date()),
                            message: dto.effectiveClientSecret ?? "Payment intention created on backend."
                        )
                        continuation.resume(returning: response)
                        cancellable?.cancel()
                    }
                )
        }
    }

    func checkStatus(intentionId: String) async throws -> PaymentIntentionStatusDTO {
        let endpoint = PaymentEndpoints.getIntentionStatus(id: intentionId)
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkService.request(endpoint)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: PaymentError.networkFailure(error.localizedDescription))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { (dto: PaymentIntentionStatusDTO) in
                        continuation.resume(returning: dto)
                        cancellable?.cancel()
                    }
                )
        }
    }
}
