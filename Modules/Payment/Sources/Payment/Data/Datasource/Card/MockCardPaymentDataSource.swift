//
//  MockCardPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

private final class PaymentBundleToken {}

/// Simulates a card payment API with a 2-second network delay.
///
/// **Test triggers:**
/// - Any card number ending in `0000` → throws `CardPaymentError.simulatedFailure`
/// - All other valid cards            → returns a successful `CardPaymentResponseDTO`
final class MockCardPaymentDataSource: CardPaymentDataSourceProtocol, Sendable {
    
    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }
    
    // MARK: CardPaymentDataSourceProtocol
    
    func processPayment(_ request: CardPaymentRequestDTO) async throws -> CardPaymentResponseDTO {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate error case: card ending with "0000"
        if request.cardNumber.hasSuffix("0000") {
            throw CardPaymentError.simulatedFailure
        }
        
        let last4 = String(request.cardNumber.suffix(4))
        
        let packageTitle = NSLocalizedString(
            "package_title_reciter_subscription",
            bundle: Self.bundle,
            value: "Reciter Subscription",
            comment: "Title for reciter subscription package"
        )
        
        let messageFormat = NSLocalizedString(
            "payment_completed_success_format",
            bundle: Self.bundle,
            value: "Payment completed successfully via %@.",
            comment: "Success message format with card provider"
        )
        let message = String(format: messageFormat, request.cardProvider)
        
        // Build a mock success response
        return CardPaymentResponseDTO(
            transactionID: generateTransactionID(),
            status: "success",
            amount: request.amount,
            cardProvider: request.cardProvider,
            last4: last4,
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
