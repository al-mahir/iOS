//
//  RealtimeConnecting.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import Combine

public protocol RealtimeConnecting: AnyObject, Sendable {

    var connectionStatePublisher: AnyPublisher<RealtimeConnectionState, Never> { get }

    var currentState: RealtimeConnectionState { get }

    var didReconnectPublisher: AnyPublisher<Void, Never> { get }

    func connect(url: URL, authToken: String) async throws

    func disconnect() async

    func subscribe(topic: String) -> AnyPublisher<RealtimeEventEnvelope, Never>

    func stream(for topic: String) -> AsyncStream<RealtimeEventEnvelope>

    func unsubscribe(topic: String)
}
