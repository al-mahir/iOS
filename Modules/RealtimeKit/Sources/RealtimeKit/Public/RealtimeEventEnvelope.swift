//
//  RealtimeEventEnvelope.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public struct RealtimeEventEnvelope: Sendable, Equatable, Codable {

    public let eventType: String

    public let payload: Data

    public init(eventType: String, payload: Data) {
        self.eventType = eventType
        self.payload = payload
    }

    public func decodePayload<T: Decodable>(
        as type: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try decoder.decode(type, from: payload)
    }
}
