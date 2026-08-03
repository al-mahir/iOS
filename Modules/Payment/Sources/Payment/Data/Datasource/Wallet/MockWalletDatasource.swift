//
//  MockWalletDatasource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Foundation


/// Simulates the Paymob wallet API with a 2-second network delay.
///
/// **Test triggers:**
/// - Any phone number ending in `0000` → throws `PaymentError.simulatedFailure`
/// - All other valid numbers         → returns a successful `PaymentResponseDTO`
final class MockWalletDataSource: WalletDataSourceProtocol, Sendable {

    // MARK: PaymentDataSourceProtocol

    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Simulate error case: phone ending with "0000"
        if request.phoneNumber.hasSuffix("0000") {
            throw PaymentError.simulatedFailure
        }

        // Build a mock success response
        return WalletPaymentResponseDTO(
            transactionID: generateTransactionID(),
            status: "success",
            amount: request.amount,
            walletProvider: request.walletProvider,
            phoneNumber: request.phoneNumber,
            packageTitle: "Reciter Subscription",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            message: "Payment completed successfully via \(request.walletProvider)."
        )
    }

    // MARK: Helpers

    private func generateTransactionID() -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16).uppercased()
        return "TXN-\(uuid)"
    }
}
