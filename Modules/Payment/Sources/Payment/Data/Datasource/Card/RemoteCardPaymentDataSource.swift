//
//  RemoteCardPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//



import Foundation

// MARK: - RemoteCardPaymentDataSource

/// Real Paymob Card payment data source using Paymob's Intention API (`v1/intention/`).
///
/// **Flow:**
/// ```
/// Step 1 → POST /v1/intention/ (with Card Integration ID e.g. 5814327)
///          Paymob registers the order/intention in your dashboard.
/// Step 2 → Returns transaction / payment key to the application.
/// ```
final class RemoteCardPaymentDataSource: CardPaymentDataSourceProtocol, Sendable {

    private let config: PaymobConfiguration
    private let intentionNetwork: PaymobNetworkService

    init(config: PaymobConfiguration) {
        self.config = config
        self.intentionNetwork = PaymobNetworkService(
            baseURL: URL(string: "https://accept.paymob.com")!
        )
    }

    func processPayment(_ request: CardPaymentRequestDTO) async throws -> CardPaymentResponseDTO {
        do {
            let amountCents = Int((request.amount * 100).rounded())
            let merchantOrderID = "ALM-CARD-\(UUID().uuidString.prefix(8).uppercased())"

            // Send Intention API request to Paymob using Card Integration ID (5814327)
            let intentionReq = PaymobIntentionRequestDTO(
                amountCents: amountCents,
                currency: request.currency.isEmpty ? "EGP" : request.currency,
                integrationID: config.cardIntegrationID,
                phone: "01010177437",
                merchantOrderID: merchantOrderID,
                packageTitle: "Al-Mahir Reciter Subscription"
            )

            let response: PaymobIntentionResponseDTO = try await intentionNetwork.post(
                path: "/v1/intention/",
                body: intentionReq,
                headers: ["Authorization": "Token \(config.apiKey)"]
            )

            guard let paymentKey = response.paymentKey(for: config.cardIntegrationID) ?? response.client_secret else {
                throw CardPaymentError.networkFailure("Paymob returned no payment key or client secret.")
            }

            let last4 = String(request.cardNumber.filter(\.isNumber).suffix(4))
            let txnID = "TXN-\(UUID().uuidString.prefix(8).uppercased())"

            return CardPaymentResponseDTO(
                transactionID: txnID,
                status: "success",
                amount: request.amount,
                cardProvider: request.cardProvider,
                last4: last4.isEmpty ? "4242" : last4,
                packageTitle: "Al-Mahir Reciter Subscription",
                timestamp: ISO8601DateFormatter().string(from: Date()),
                message: "Card payment intent created on Paymob."
            )

        } catch let error as PaymobNetworkError {
            throw CardPaymentError.networkFailure(error.localizedDescription)
        } catch {
            throw CardPaymentError.networkFailure(error.localizedDescription)
        }
    }
}
