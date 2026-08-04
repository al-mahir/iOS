//
//  CircleSocketDataSource.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation
import RealtimeKit

public final class CircleSocketDataSource: @unchecked Sendable {

    private let client: any RealtimeConnecting
    private var cancellables = Set<AnyCancellable>()

    private static let socketURL = URL(
        string: "wss://almahir-production.up.railway.app/ws"
    )!

    public init(client: any RealtimeConnecting = RealtimeClient()) {
        self.client = client
    }

    // MARK: - Connection

    func connect(authToken: String) async throws {
        guard client.currentState != .connected else { return }
        try await client.connect(url: Self.socketURL, authToken: authToken)
    }

    func disconnect() async {
        await client.disconnect()
    }

    var isConnected: AnyPublisher<Bool, Never> {
        client.connectionStatePublisher
            .map { $0 == .connected }
            .eraseToAnyPublisher()
    }

    // MARK: - Topic 1: Owner pending-requests feed

    func observeOwnerRequests(circleId: String) -> AnyPublisher<
        CircleSocketEvent, Never
    > {
        client
            .subscribe(topic: CircleTopic.ownerRequests(circleId: circleId))
            .compactMap { [weak self] envelope in
                self?.mapOwnerRequestEvent(envelope)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Topic 2: Member's own request status

    func observeMembershipStatus(membershipId: String) -> AnyPublisher<
        CircleSocketEvent, Never
    > {
        client
            .subscribe(
                topic: CircleTopic.membershipStatus(membershipId: membershipId)
            )
            .compactMap { [weak self] envelope in
                self?.mapMembershipStatusEvent(envelope)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Topic 3: Circle-wide roster / lifecycle

    func observeCircleEvents(circleId: String) -> AnyPublisher<
        CircleSocketEvent, Never
    > {
        client
            .subscribe(topic: CircleTopic.circleEvents(circleId: circleId))
            .compactMap { [weak self] envelope in
                self?.mapCircleEvent(envelope)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Unsubscribe helpers

    func unsubscribeOwnerRequests(circleId: String) {
        client.unsubscribe(topic: CircleTopic.ownerRequests(circleId: circleId))
    }

    func unsubscribeMembershipStatus(membershipId: String) {
        client.unsubscribe(
            topic: CircleTopic.membershipStatus(membershipId: membershipId)
        )
    }

    func unsubscribeCircleEvents(circleId: String) {
        client.unsubscribe(topic: CircleTopic.circleEvents(circleId: circleId))
    }

    // MARK: - Private: Event mapping

    private func mapOwnerRequestEvent(_ envelope: RealtimeEventEnvelope)
        -> CircleSocketEvent?
    {
        switch envelope.eventType {
        case CircleEventType.joinRequestReceived:
            guard
                let dto = try? envelope.decodePayload(
                    as: PendingJoinRequestDTO.self
                )
            else {
                return nil
            }
            return .joinRequestReceived(dto.toDomain())

        case CircleEventType.joinRequestRemoved:
            let membershipId =
                (try? envelope.decodePayload(as: String.self))
                ?? String(data: envelope.payload, encoding: .utf8)
                ?? ""
            return .joinRequestRemoved(membershipId: membershipId)

        default:
            return nil
        }
    }

    private func mapMembershipStatusEvent(_ envelope: RealtimeEventEnvelope)
        -> CircleSocketEvent?
    {
        switch envelope.eventType {
        case CircleEventType.requestApproved:
            guard
                let dto = try? envelope.decodePayload(as: CircleMemberDTO.self)
            else {
                return nil
            }
            return .requestApproved(dto.toDomain())

        case CircleEventType.requestRejected:
            let reason =
                (try? envelope.decodePayload(as: String.self))
                ?? String(data: envelope.payload, encoding: .utf8)
                ?? "Request rejected."
            return .requestRejected(reason: reason)

        default:
            return nil
        }
    }

    private func mapCircleEvent(_ envelope: RealtimeEventEnvelope)
        -> CircleSocketEvent?
    {
        switch envelope.eventType {
        case CircleEventType.memberJoined:
            guard
                let dto = try? envelope.decodePayload(as: CircleMemberDTO.self)
            else {
                return nil
            }
            return .memberJoined(dto.toDomain())

        case CircleEventType.memberLeft:
            let userId = rawString(from: envelope)
            return .memberLeft(userId: userId)

        case CircleEventType.memberRemoved:
            let userId = rawString(from: envelope)
            return .memberRemoved(userId: userId)

        case CircleEventType.circleStarted:
            let circleId = rawString(from: envelope)
            return .circleStarted(circleId: circleId)

        case CircleEventType.circleEnded:
            let circleId = rawString(from: envelope)
            return .circleEnded(circleId: circleId)

        case CircleEventType.circleCancelled:
            let circleId = rawString(from: envelope)
            return .circleCancelled(circleId: circleId)

        default:
            return nil
        }
    }

    private func rawString(from envelope: RealtimeEventEnvelope) -> String {
        if let quoted = try? envelope.decodePayload(as: String.self) {
            return quoted
        }
        return String(data: envelope.payload, encoding: .utf8) ?? ""
    }
}

// MARK: - STOMP Topic Constants

private enum CircleTopic {
    static func ownerRequests(circleId: String) -> String {
        "/topic/circles/\(circleId)/requests"
    }

    static func membershipStatus(membershipId: String) -> String {
        "/topic/circle-memberships/\(membershipId)"
    }

    static func circleEvents(circleId: String) -> String {
        "/topic/circles/\(circleId)"
    }
}

// MARK: - STOMP Event Types

private enum CircleEventType {
    // Topic 1
    static let joinRequestReceived = "CIRCLE_JOIN_REQUEST_RECEIVED"
    static let joinRequestRemoved = "CIRCLE_JOIN_REQUEST_REMOVED"

    // Topic 2
    static let requestApproved = "REQUEST_APPROVED"
    static let requestRejected = "REQUEST_REJECTED"

    // Topic 3
    static let memberJoined = "MEMBER_JOINED"
    static let memberLeft = "MEMBER_LEFT"
    static let memberRemoved = "MEMBER_REMOVED"
    static let circleStarted = "CIRCLE_STARTED"
    static let circleEnded = "CIRCLE_ENDED"
    static let circleCancelled = "CIRCLE_CANCELLED"
}
