//
//  LiveSessionError.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public enum LiveSessionError: Error, LocalizedError, Equatable {
    case notHost
    case joinFailed(reason: String)
    case leaveFailed(reason: String)
    case endFailed(reason: String)
    case tokenRenewalFailed(reason: String)
    case socketSubscriptionFailed(reason: String)
    case unknown(reason: String)

    public var errorDescription: String? {
        switch self {
        case .notHost:
            return "Only the host can end the live session."
        case .joinFailed(let reason):
            return "Failed to join live session: \(reason)"
        case .leaveFailed(let reason):
            return "Failed to leave live session cleanly: \(reason)"
        case .endFailed(let reason):
            return "Failed to end live session: \(reason)"
        case .tokenRenewalFailed(let reason):
            return "Failed to renew media token: \(reason)"
        case .socketSubscriptionFailed(let reason):
            return "Failed to subscribe to realtime events: \(reason)"
        case .unknown(let reason):
            return reason
        }
    }
}
