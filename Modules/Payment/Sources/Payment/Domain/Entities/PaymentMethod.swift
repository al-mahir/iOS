//
//  PaymentMethod.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI


public enum PaymentMethod: String, CaseIterable, Identifiable, Sendable {
    case wallet = "wallet"
    case card = "card"
    
    public var id: String { rawValue }
    
    // MARK: Display
    
    public var displayName: String {
        switch self {
        case .wallet: return "Mobile Wallet"
        case .card: return "Credit/Debit Card"
        }
    }
    
    public var icon: String {
        switch self {
        case .wallet: return "wallet.pass.fill"
        case .card: return "creditcard.fill"
        }
    }
}
