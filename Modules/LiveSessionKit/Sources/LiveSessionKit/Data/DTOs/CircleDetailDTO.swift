//
//  CircleDetailDTO.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public struct CircleDetailDTO: Codable, Sendable {
    public let id: String?
    public let channelName: String?
    public let agoraToken: String?
    public let token: String?

    public var resolvedToken: String? {
        if let t = agoraToken, !t.isEmpty { return t }
        if let t = token, !t.isEmpty { return t }
        return nil
    }

    public init(
        id: String? = nil,
        channelName: String? = nil,
        agoraToken: String? = nil,
        token: String? = nil
    ) {
        self.id = id
        self.channelName = channelName
        self.agoraToken = agoraToken
        self.token = token
    }
}
