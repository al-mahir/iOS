//
//  PaymentViewState.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//




import Foundation
import Combine

// MARK: - PaymentViewState

public enum PaymentViewState: Equatable {
    case idle
    case loading
    /// OTP sent — user must confirm in their wallet app. Carries the Paymob transaction ID.
    case awaitingConfirmation(transactionID: String)
    case success(PaymentResult)
    case cardSuccess(CardPaymentResult)
    case error(String)

    public static func == (lhs: PaymentViewState, rhs: PaymentViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.awaitingConfirmation(let a), .awaitingConfirmation(let b)):
            return a == b
        case (.success(let a), .success(let b)):
            return a.transactionID == b.transactionID
        case (.cardSuccess(let a), .cardSuccess(let b)):
            return a.transactionID == b.transactionID
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

