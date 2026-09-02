//
//  RealtimeConnectionState.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public enum RealtimeConnectionState: Sendable, Equatable {

    case disconnected

    case connecting

    case connected

    case reconnecting(attempt: Int)

    case failed(RealtimeError)
}
