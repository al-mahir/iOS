//
//  RealtimeFrameDecoder.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

struct RealtimeFrameDecoder {
    private static let jsonDecoder = JSONDecoder()

    /// Decodes an incoming STOMP message payload and headers into a `RealtimeEventEnvelope`.
    /// - Parameters:
    ///   - body: Raw message body (Data or String or Dictionary).
    ///   - headers: STOMP frame headers dictionary.
    /// - Returns: A decoded `RealtimeEventEnvelope`.
    /// - Throws: `RealtimeError.malformedEnvelope` if parsing fails.
    static func decode(body: Any?, headers: [String: String]) throws -> RealtimeEventEnvelope {
        guard let body = body else {
            throw RealtimeError.malformedEnvelope
        }

        let data: Data
        if let rawData = body as? Data {
            data = rawData
        } else if let rawString = body as? String, let stringData = rawString.data(using: .utf8) {
            data = stringData
        } else if JSONSerialization.isValidJSONObject(body), let jsonObjectData = try? JSONSerialization.data(withJSONObject: body) {
            data = jsonObjectData
        } else {
            throw RealtimeError.malformedEnvelope
        }

        if let envelope = try? jsonDecoder.decode(RealtimeEventEnvelope.self, from: data) {
            return envelope
        }

        
        let eventTypeFromHeader = headers["event-type"] ?? headers["eventType"] ?? headers["type"]
        if let eventType = eventTypeFromHeader, !eventType.isEmpty {
            return RealtimeEventEnvelope(eventType: eventType, payload: data)
        }


        if let jsonDict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
           let eventType = jsonDict["eventType"] as? String {
            if let nestedPayload = jsonDict["payload"] {
                let payloadData: Data
                if let payloadDict = nestedPayload as? [String: Any], let pData = try? JSONSerialization.data(withJSONObject: payloadDict) {
                    payloadData = pData
                } else if let payloadStr = nestedPayload as? String, let pData = payloadStr.data(using: .utf8) {
                    payloadData = pData
                } else {
                    payloadData = data
                }
                return RealtimeEventEnvelope(eventType: eventType, payload: payloadData)
            } else {
                return RealtimeEventEnvelope(eventType: eventType, payload: data)
            }
        }

        throw RealtimeError.malformedEnvelope
    }
}
