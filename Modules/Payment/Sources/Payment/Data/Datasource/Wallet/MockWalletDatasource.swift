//
//  MockWalletDatasource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

private final class PaymentBundleToken {}

/// Simulates the Paymob wallet API with a 2-second network delay.
///
/// **Test triggers:**
/// - Any phone number ending in `0000` → throws `PaymentError.simulatedFailure`
/// - All other valid numbers         → returns a successful `PaymentResponseDTO`
final class MockWalletDataSource: WalletDataSourceProtocol, Sendable {

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    // MARK: PaymentDataSourceProtocol

    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Simulate error case: phone ending with "0000"
        if request.phoneNumber.hasSuffix("0000") {
            throw PaymentError.simulatedFailure
        }

        let packageTitle = NSLocalizedString(
            "package_title_reciter_subscription",
            bundle: Self.bundle,
            value: "Reciter Subscription",
            comment: "Title for reciter subscription package"
        )

        let messageFormat = NSLocalizedString(
            "payment_completed_success_wallet_format",
            bundle: Self.bundle,
            value: "Payment completed successfully via %@.",
            comment: "Success message format with wallet provider"
        )
        let message = String(format: messageFormat, request.walletProvider)

        // Build a mock success response
        return WalletPaymentResponseDTO(
            transactionID: generateTransactionID(),
            status: "success",
            amount: request.amount,
            walletProvider: request.walletProvider,
            phoneNumber: request.phoneNumber,
            packageTitle: packageTitle,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            message: message
        )
    }

    func checkStatus(intentionId: String) async throws -> PaymentIntentionStatusDTO {
        let json = "{\"id\": \"\(intentionId)\", \"status\": \"success\", \"isSuccess\": true}".data(using: .utf8)!
        return try JSONDecoder().decode(PaymentIntentionStatusDTO.self, from: json)
    }

    // MARK: Helpers

    private func generateTransactionID() -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16).uppercased()
        return "TXN-\(uuid)"
    }
}
