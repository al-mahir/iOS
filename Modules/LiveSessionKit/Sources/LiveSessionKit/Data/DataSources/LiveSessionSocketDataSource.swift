//
//  LiveSessionSocketDataSource.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine
import RealtimeKit

public protocol LiveSessionSocketDataSourceProtocol: Sendable {
    func subscribeToCircleTopic(circleId: String) -> AnyPublisher<RealtimeEventEnvelope, Never>
    func unsubscribeFromCircleTopic(circleId: String)
    var didReconnectPublisher: AnyPublisher<Void, Never> { get }
}

public final class LiveSessionSocketDataSource: LiveSessionSocketDataSourceProtocol, @unchecked Sendable {
    private let realtimeClient: RealtimeConnecting

    public var didReconnectPublisher: AnyPublisher<Void, Never> {
        realtimeClient.didReconnectPublisher
    }

    public init(realtimeClient: RealtimeConnecting) {
        self.realtimeClient = realtimeClient
    }

    public func subscribeToCircleTopic(circleId: String) -> AnyPublisher<RealtimeEventEnvelope, Never> {
        let topic = topicForCircle(circleId)
        return realtimeClient.subscribe(topic: topic)
    }

    public func unsubscribeFromCircleTopic(circleId: String) {
        let topic = topicForCircle(circleId)
        realtimeClient.unsubscribe(topic: topic)
    }

    private func topicForCircle(_ circleId: String) -> String {
        "/topic/circles/\(circleId)/host"
    }
}
