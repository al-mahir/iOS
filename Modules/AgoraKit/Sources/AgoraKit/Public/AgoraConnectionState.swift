//
//  AgoraConnectionState.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public enum AgoraConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(AgoraSessionError)
}
