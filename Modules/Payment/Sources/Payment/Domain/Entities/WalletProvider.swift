//
//  WalletProvider.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import SwiftUI


public enum WalletProvider: String, CaseIterable, Identifiable, Sendable {
    case vodafoneCash = "vodafone_cash"
    case orangeCash   = "orange_cash"
    case eAndMoney    = "e_and_money"
    case wePay        = "we_pay"

    public var id: String { rawValue }

    // MARK: Display

    public var displayName: String {
        switch self {
        case .vodafoneCash: return "Vodafone Cash"
        case .orangeCash:   return "Orange Cash"
        case .eAndMoney:    return "e& money"
        case .wePay:        return "We Pay"
        }
    }

    public var tagline: String {
        switch self {
        case .vodafoneCash: return "Pay with your Vodafone wallet"
        case .orangeCash:   return "Pay with your Orange wallet"
        case .eAndMoney:    return "Pay with e& mobile money"
        case .wePay:        return "Pay with WE telecom wallet"
        }
    }

    // MARK: Brand Colors (hex)

    public var brandPrimaryHex: String {
        switch self {
        case .vodafoneCash: return "#E60026"
        case .orangeCash:   return "#FF6600"
        case .eAndMoney:    return "#000000"
        case .wePay:        return "#0072BC"
        }
    }

    public var brandSecondaryHex: String {
        switch self {
        case .vodafoneCash: return "#9B0019"
        case .orangeCash:   return "#CC5200"
        case .eAndMoney:    return "#3D3D3D"
        case .wePay:        return "#005291"
        }
    }

    // MARK: SF Symbol icon name

    public var symbolName: String {
        switch self {
        case .vodafoneCash: return "wave.3.right.circle.fill"
        case .orangeCash:   return "circle.hexagongrid.fill"
        case .eAndMoney:    return "e.circle.fill"
        case .wePay:        return "w.circle.fill"
        }
    }

    // MARK: Expected phone prefix(es)

    /// The dialing prefixes that match this provider (Egyptian mobile).
    public var expectedPrefixes: [String] {
        switch self {
        case .vodafoneCash: return ["010"]
        case .orangeCash:   return ["012"]
        case .eAndMoney:    return ["011"]
        case .wePay:        return ["015"]
        }
    }
}
