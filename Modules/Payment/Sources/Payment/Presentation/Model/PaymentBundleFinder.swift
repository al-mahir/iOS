//
//  PaymentBundleFinder.swift
//  Payment
//
//  Created by Basmala Abuzied Ahmed on 16/08/2026.
//


import Foundation

private final class PaymentBundleFinder {}

extension Bundle {
    /// Bundle targeting the Payment module for localized resources.
    public static var paymentBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleFinder.self)
        #endif
    }
}