//
//  AgoraTokenRefreshProvider.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public protocol AgoraTokenRefreshProvider: Sendable {
    func refreshToken() async throws -> String
}
