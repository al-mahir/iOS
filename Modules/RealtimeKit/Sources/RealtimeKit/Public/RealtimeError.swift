//
//  RealtimeError.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public enum RealtimeError: Error, Sendable, Equatable {

    case connectionFailed(reason: String)

    case authenticationRejected

    case subscriptionFailed(topic: String)

    case malformedEnvelope

    case transportError(description: String)

    case notConnected
}
