//
//  InstantMeetingsRealtimeDataSource.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation
import Combine
import NetworkKit
import RealtimeKit

public protocol InstantMeetingsRealtimeDataSourceProtocol: Sendable {
    func subscribeToRequestTopic(requestId: String) -> AnyPublisher<InstantMeetingRealtimeEventDTO, Never>
    func unsubscribeFromRequestTopic(requestId: String)
}

public final class InstantMeetingsRealtimeDataSource: InstantMeetingsRealtimeDataSourceProtocol, @unchecked Sendable {
    private let realtimeClient: RealtimeConnecting
    private let accessTokenProvider: () -> String?
    private let socketURL: URL

    public init(
        realtimeClient: RealtimeConnecting,
        accessTokenProvider: @escaping () -> String? = {
            AppRequestInterceptors.shared.tokenProvider?()
        },
        socketURL: URL = URL(string: BaseURLType.socketUrl.urlString)!
    ) {
        self.realtimeClient = realtimeClient
        self.accessTokenProvider = accessTokenProvider
        self.socketURL = socketURL
    }

    public func subscribeToRequestTopic(requestId: String) -> AnyPublisher<InstantMeetingRealtimeEventDTO, Never> {
        let topic = topicForRequest(requestId)
        let publisher = realtimeClient.subscribe(topic: topic)
        connectIfNeeded()

        return publisher
            .compactMap { envelope -> InstantMeetingRealtimeEventDTO? in
                Self.parseEvent(envelope, defaultRequestId: requestId)
            }
            .eraseToAnyPublisher()
    }

    public func unsubscribeFromRequestTopic(requestId: String) {
        let topic = topicForRequest(requestId)
        realtimeClient.unsubscribe(topic: topic)
    }

    private func topicForRequest(_ requestId: String) -> String {
        "/topic/meeting-requests/\(requestId)"
    }

    private func connectIfNeeded() {
        switch realtimeClient.currentState {
        case .disconnected, .failed:
            break
        case .connecting, .connected, .reconnecting:
            return
        }

        guard let token = accessTokenProvider()?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !token.isEmpty else {
            return
        }

        Task { [realtimeClient, socketURL] in
            try? await realtimeClient.connect(url: socketURL, authToken: token)
        }
    }

    private static func parseEvent(_ envelope: RealtimeEventEnvelope, defaultRequestId: String) -> InstantMeetingRealtimeEventDTO? {
        switch envelope.eventType {
        case "REQUEST_ACCEPTED":
            if let dto = try? envelope.decodePayload(as: AcceptResponseDTO.self) {
                return .accepted(dto)
            }
            return nil

        case "REQUEST_DECLINED":
            let reason = (try? envelope.decodePayload(as: String.self)) ?? String(data: envelope.payload, encoding: .utf8)
            return .declined(reason: reason)

        case "REQUEST_CANCELLED":
            let reqId = (try? envelope.decodePayload(as: String.self)) ?? defaultRequestId
            return .cancelled(requestId: reqId)

        case "REQUEST_EXPIRED":
            let reqId = (try? envelope.decodePayload(as: String.self)) ?? defaultRequestId
            return .expired(requestId: reqId)

        case "MEETING_ENDED":
            let reqId = (try? envelope.decodePayload(as: String.self)) ?? defaultRequestId
            return .ended(requestId: reqId)

        default:
            return nil
        }
    }
}
