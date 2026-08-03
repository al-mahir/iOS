//
//  CardProvider.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI

public enum CardProvider: String, CaseIterable, Identifiable, Sendable {
    case visa = "visa"
    case mastercard = "mastercard"
    
    public var id: String { rawValue }
    
    // MARK: Display
    
    public var displayName: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        }
    }
    
    public var tagline: String {
        switch self {
        case .visa: return "Pay securely with Visa"
        case .mastercard: return "Pay securely with Mastercard"
        }
    }
    
    // MARK: Brand Colors (hex)
    
    public var brandPrimaryHex: String {
        switch self {
        case .visa: return "#1A1F71"
        case .mastercard: return "#EB001B"
        }
    }
    
    public var brandSecondaryHex: String {
        switch self {
        case .visa: return "#F7B600"
        case .mastercard: return "#F79E1B"
        }
    }
    
    // MARK: SF Symbol icon name
    
    public var symbolName: String {
        switch self {
        case .visa: return "creditcard.fill"
        case .mastercard: return "creditcard.circle.fill"
        }
    }
}
