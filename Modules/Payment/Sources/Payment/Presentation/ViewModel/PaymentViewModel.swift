//
//  PaymentViewModel.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//



import Foundation
import Combine


@MainActor
public final class PaymentViewModel: ObservableObject {

    // MARK: Published State

    @Published public var viewState: PaymentViewState = .idle
    @Published public var selectedPaymentMethod: PaymentMethod = .wallet
    
    // Wallet State
    @Published public var walletNumber: String = ""
    @Published public var selectedProvider: WalletProvider?
    @Published public var phoneError: String?
    
    // Card State
    @Published public var selectedCardProvider: CardProvider?
    @Published public var cardNumber = ""
    @Published public var expiryDate = ""
    @Published public var cvv = ""
    @Published public var holderName = ""
    @Published public var cardError: String?

    // MARK: Read-only Package

    public let package: SubscriptionPackage

    // MARK: Dependencies

    private let useCase: ProcessWalletPaymentUseCase
    private let cardUseCase: ProcessCardPaymentUseCase

    // MARK: Init

    public init(
        package: SubscriptionPackage,
        useCase: ProcessWalletPaymentUseCase,
        cardUseCase: ProcessCardPaymentUseCase
    ) {
        self.package = package
        self.useCase = useCase
        self.cardUseCase = cardUseCase
    }

    // MARK: Actions

    /// Selects the given wallet provider and clears any previous phone validation error.
    public func selectProvider(_ provider: WalletProvider) {
        selectedProvider = provider
        phoneError = nil
    }
    
    /// Selects the given card provider and clears any previous card validation error.
    public func selectCardProvider(_ provider: CardProvider) {
        selectedCardProvider = provider
        cardError = nil
    }

    /// Validates input, calls the use case, and updates `viewState` accordingly.
    ///
    /// - For **MockPaymentDataSource**: moves directly to `.success` after 2s.
    /// - For **RemotePaymentDataSource**: moves to `.awaitingConfirmation` after Paymob
    ///   sends the OTP SMS to the user's wallet.
    public func pay() {
        guard let provider = selectedProvider else { return }
        phoneError = nil
        guard viewState != .loading else { return }
        viewState = .loading

        Task {
            do {
                let result = try await useCase.execute(
                    package: package,
                    provider: provider,
                    phoneNumber: walletNumber
                )

                // Real Paymob: result comes back with pending=true first.
                // The PaymentRepositoryImpl decides whether to mark as pending or success
                // based on the DTO status field.
                if result.transactionID.hasPrefix("PENDING-") {
                    // Extract the real transaction ID after the prefix
                    let txnID = String(result.transactionID.dropFirst("PENDING-".count))
                    viewState = .awaitingConfirmation(transactionID: txnID)
                } else {
                    viewState = .success(result)
                }

            } catch PaymentError.invalidPhoneNumber {
                viewState = .idle
                phoneError = "Please enter a valid 11-digit Egyptian mobile number."
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
    
    public func payWithCard() {
        guard let provider = selectedCardProvider else { return }
        cardError = nil
        guard viewState != .loading else { return }
        viewState = .loading
        
        // Split "MM/YY" into month and year
        let expiryParts = expiryDate.split(separator: "/")
        let month = expiryParts.count > 0 ? String(expiryParts[0]) : ""
        let year = expiryParts.count > 1 ? String(expiryParts[1]) : ""
        
        Task {
            do {
                let result = try await cardUseCase.execute(
                    package: package,
                    provider: provider,
                    cardNumber: cardNumber.filter(\.isNumber),
                    expiryMonth: month,
                    expiryYear: year,
                    cvv: cvv,
                    holderName: holderName
                )
                viewState = .cardSuccess(result)
            } catch let error as CardPaymentError {
                viewState = .idle
                cardError = error.localizedDescription
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    /// Called when the user taps "Payment Confirmed" on the awaiting screen.
    /// In a real scenario this would be triggered by a webhook / push notification.
    /// Here we accept the confirmation at face value and show success.
    public func confirmPaymentManually(transactionID: String) {
        guard let provider = selectedProvider else { return }
        let result = PaymentResult(
            transactionID: transactionID,
            amount: package.priceEGP,
            walletProvider: provider,
            packageTitle: package.title,
            timestamp: Date(),
            maskedPhoneNumber: maskPhone(walletNumber)
        )
        viewState = .success(result)
    }

    /// Resets the view to `.idle`, allowing the user to retry.
    public func resetState() {
        viewState = .idle
        phoneError = nil
        cardError = nil
    }

    // MARK: Computed

    /// Whether the Pay Now button should be active for wallet.
    public var canPay: Bool {
        selectedProvider != nil && walletNumber.filter(\.isNumber).count == 11
    }
    
    /// Whether the Pay Now button should be active for card.
    public var canPayCard: Bool {
        selectedCardProvider != nil &&
        cardNumber.filter(\.isNumber).count >= 15 &&
        expiryDate.count == 5 &&
        cvv.count >= 3 &&
        !holderName.isEmpty
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
