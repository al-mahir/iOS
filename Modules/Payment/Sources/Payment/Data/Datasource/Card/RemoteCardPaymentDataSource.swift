//
//  RemoteCardPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation
import NetworkKit
import Combine

private final class PaymentBundleToken {}

/// Real backend payment intention data source for Card payments.
/// Hits `POST /api/payment/intentions` and `GET /api/payment/intentions/{id}/status`.
final class RemoteCardPaymentDataSource: CardPaymentDataSourceProtocol, Sendable {

    private let networkService: NetworkServiceProtocol

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func processPayment(_ request: CardPaymentRequestDTO) async throws -> CardPaymentResponseDTO {
        let idempotencyKey = UUID().uuidString
        let packageCode = request.packageID.hasPrefix("pkg-") ? request.packageID : "pkg-basic"

        let endpoint = PaymentEndpoints.createIntention(
            packageId: packageCode,
            method: "card",
            idempotencyKey: idempotencyKey
        )

        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = networkService.request(endpoint)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: CardPaymentError.networkFailure(error.localizedDescription))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { (dto: PaymentIntentionDTO) in
                        let last4 = String(request.cardNumber.filter(\.isNumber).suffix(4))
                        
                        let packageTitle = NSLocalizedString(
                            "package_title_al_mahir_reciter_subscription",
                            bundle: Self.bundle,
                            value: "Al-Mahir Reciter Subscription",
                            comment: "Title for Al-Mahir reciter subscription package"
                        )
                        
                        let response = CardPaymentResponseDTO(
                            transactionID: dto.intentionId,
                            status: "pending",
                            amount: request.amount,
                            cardProvider: request.cardProvider,
                            last4: last4.isEmpty ? "4242" : last4,
                            packageTitle: packageTitle,
                            timestamp: ISO8601DateFormatter().string(from: Date()),
                            message: dto.clientSecret
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
                            continuation.resume(throwing: CardPaymentError.networkFailure(error.localizedDescription))
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
