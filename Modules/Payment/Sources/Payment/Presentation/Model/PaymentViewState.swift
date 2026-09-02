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
    /// Paymob Checkout Web Intention view presented to complete payment
    case checkout(clientSecret: String, publicKey: String, intentionId: String)
    case success(PaymentResult)
    case cardSuccess(CardPaymentResult)
    case error(String)

    public static func == (lhs: PaymentViewState, rhs: PaymentViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.awaitingConfirmation(let a), .awaitingConfirmation(let b)):
            return a == b
        case (.checkout(let cs1, let pk1, let id1), .checkout(let cs2, let pk2, let id2)):
            return cs1 == cs2 && pk1 == pk2 && id1 == id2
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
