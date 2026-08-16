//
//  RemoteWalletPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation
import NetworkKit
import Combine

private final class PaymentBundleToken {}

final class RemoteWalletPaymentDataSource: WalletDataSourceProtocol, Sendable {

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

    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO {
        let idempotencyKey = UUID().uuidString
        let packageCode = request.packageID.hasPrefix("pkg-") ? request.packageID : "pkg-basic"

        let endpoint = PaymentEndpoints.createIntention(
            packageId: packageCode,
            method: request.walletProvider.lowercased(),
            idempotencyKey: idempotencyKey
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
                    receiveValue: { (dto: PaymentIntentionDTO) in
                        let packageTitle = NSLocalizedString(
                            "package_title_al_mahir_reciter_subscription",
                            bundle: Self.bundle,
                            value: "Al-Mahir Reciter Subscription",
                            comment: "Title for Al-Mahir reciter subscription package"
                        )

                        let response = WalletPaymentResponseDTO(
                            transactionID: dto.intentionId,
                            status: "pending",
                            amount: request.amount,
                            walletProvider: request.walletProvider,
                            phoneNumber: request.phoneNumber,
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
