//
//  RemoteWalletPaymentDataSource.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Foundation


///
/// **New Secret Key** (`egy_sk_test_...` / `egy_sk_live_...`):
///   Uses the Intention API (`/v1/intention/`) — single call replaces steps 1-3.
///   Auth via HTTP header: `Authorization: Token <secret_key>`
///
/// **Legacy API Key** (long alphanumeric string):
///   Uses the classic 4-step flow (auth → order → payment_key → pay).
///   Auth via `auth_token` in JSON body.
///
final class RemoteWalletPaymentDataSource: WalletDataSourceProtocol, Sendable {

    // MARK: Dependencies

    private let network: PaymobNetworkService
    private let config: PaymobConfiguration

    /// True when using new-style Secret Keys (egy_sk_...)
    private var usesSecretKey: Bool {
        config.apiKey.hasPrefix("egy_sk_") || config.apiKey.hasPrefix("sk_")
    }

    // MARK: Init

    init(config: PaymobConfiguration) {
        self.config  = config
        self.network = PaymobNetworkService(baseURL: config.environment.baseURL)
    }

    // MARK: PaymentDataSourceProtocol

    func processPayment(_ request: WalletPaymentRequestDTO) async throws -> WalletPaymentResponseDTO {
        do {
            let provider = walletProvider(from: request.walletProvider)
            guard let integrationID = config.integrationID(for: provider) else {
                throw PaymentError.networkFailure(
                    "No integration ID configured for \(request.walletProvider). Add it to PaymobConfiguration."
                )
            }

            let amountCents = Int((request.amount * 100).rounded())
            let merchantOrderID = "ALM-\(UUID().uuidString.prefix(8).uppercased())"

            // Get payment key (different flow depending on key type)
            let paymentKey: String

            if usesSecretKey {
                // ── New API: Single Intention call ───────────────────────────
                paymentKey = try await createIntention(
                    amountCents: amountCents,
                    integrationID: integrationID,
                    phone: request.phoneNumber,
                    merchantOrderID: merchantOrderID
                )
            } else {
                // ── Legacy API: 3-step flow ─────────────────────────────────
                let authToken = try await authenticateLegacy()
                let orderID = try await registerOrderLegacy(
                    authToken: authToken,
                    amountCents: amountCents,
                    merchantOrderID: merchantOrderID
                )
                paymentKey = try await getPaymentKeyLegacy(
                    authToken: authToken,
                    amountCents: amountCents,
                    orderID: orderID,
                    integrationID: integrationID,
                    phone: request.phoneNumber
                )
            }

            // ── Step 4 (same for both): Initiate Wallet Payment ─────────────
            let walletResponse = try await initiateWalletPayment(
                paymentKey: paymentKey,
                phone: request.phoneNumber
            )

            return WalletPaymentResponseDTO(
                transactionID: String(walletResponse.id),
                status: walletResponse.pending ? "pending" : (walletResponse.success ? "success" : "failed"),
                amount: request.amount,
                walletProvider: request.walletProvider,
                phoneNumber: request.phoneNumber,
                packageTitle: "Al-Mahir Reciter Subscription",
                timestamp: ISO8601DateFormatter().string(from: Date()),
                message: walletResponse.pending
                    ? "OTP sent to your wallet. Please confirm in your wallet app."
                    : "Payment processed."
            )

        } catch let error as PaymentError {
            throw error
        } catch let error as PaymobNetworkError {
            throw PaymentError.networkFailure(error.localizedDescription)
        } catch {
            throw PaymentError.networkFailure(error.localizedDescription)
        }
    }

    // =========================================================================
    // MARK: - New API: Intention Flow (Secret Key)
    // =========================================================================

    /// Single POST to `/v1/intention/` that creates order + returns payment key.
    private func createIntention(
        amountCents: Int,
        integrationID: Int,
        phone: String,
        merchantOrderID: String
    ) async throws -> String {
        let request = PaymobIntentionRequestDTO(
            amountCents: amountCents,
            integrationID: integrationID,
            phone: phone,
            merchantOrderID: merchantOrderID,
            packageTitle: "Al-Mahir Reciter Subscription"
        )

        // Intention API lives at /v1/intention/ (not under /api/)
        // We need to use the root domain for this endpoint
        let intentionNetwork = PaymobNetworkService(
            baseURL: URL(string: "https://accept.paymob.com")!
        )

        let response: PaymobIntentionResponseDTO = try await intentionNetwork.post(
            path: "/v1/intention/",
            body: request,
            headers: ["Authorization": "Token \(config.apiKey)"]
        )

        guard let key = response.paymentKey(for: integrationID) else {
            throw PaymentError.networkFailure(
                "Paymob returned no payment key for integration \(integrationID)."
            )
        }
        return key
    }

    // =========================================================================
    // MARK: - Legacy API: 3-Step Flow (API Key)
    // =========================================================================

    private func authenticateLegacy() async throws -> String {
        let request = PaymobAuthRequestDTO(api_key: config.apiKey)
        let response: PaymobAuthResponseDTO = try await network.post(
            path: "/auth/tokens",
            body: request
        )
        return response.token
    }

    private func registerOrderLegacy(
        authToken: String,
        amountCents: Int,
        merchantOrderID: String
    ) async throws -> Int {
        let request = PaymobOrderRequestDTO(
            authToken: authToken,
            amountCents: amountCents,
            merchantOrderID: merchantOrderID,
            packageTitle: "Al-Mahir Reciter Subscription"
        )
        let response: PaymobOrderResponseDTO = try await network.post(
            path: "/ecommerce/orders",
            body: request
        )
        return response.id
    }

    private func getPaymentKeyLegacy(
        authToken: String,
        amountCents: Int,
        orderID: Int,
        integrationID: Int,
        phone: String
    ) async throws -> String {
        let request = PaymobPaymentKeyRequestDTO(
            authToken: authToken,
            amountCents: amountCents,
            orderID: orderID,
            integrationID: integrationID,
            phone: phone
        )
        let response: PaymobPaymentKeyResponseDTO = try await network.post(
            path: "/acceptance/payment_keys",
            body: request
        )
        return response.token
    }

    // =========================================================================
    // MARK: - Step 4: Wallet Payment (same for both flows)
    // =========================================================================

    private func initiateWalletPayment(
        paymentKey: String,
        phone: String
    ) async throws -> PaymobWalletPayResponseDTO {
        let request = PaymobWalletPayRequestDTO(
            source: PaymobWalletSourceDTO(phoneNumber: phone),
            payment_token: paymentKey
        )
        return try await network.post(
            path: "/acceptance/payments/pay",
            body: request
        )
    }

    // MARK: - Helpers

    private func walletProvider(from rawValue: String) -> WalletProvider {
        WalletProvider(rawValue: rawValue) ?? .vodafoneCash
    }
}
