//
//  RealtimeClient.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Combine
import Foundation

public final class RealtimeClient: RealtimeConnecting,
    RealtimeTransportDelegate, @unchecked Sendable
{
    private let transport: RealtimeTransportProtocol
    private let registry: RealtimeSubscriptionRegistry

    private let stateSubject = CurrentValueSubject<
        RealtimeConnectionState, Never
    >(.disconnected)
    private let didReconnectSubject = PassthroughSubject<Void, Never>()
    private let connectionLock = NSLock()
    private var connectionWaiters: [CheckedContinuation<Void, Error>] = []
    private var isConnectionAttemptInFlight = false
    private var connectionTimeoutTask: Task<Void, Never>?

    public var connectionStatePublisher:
        AnyPublisher<RealtimeConnectionState, Never>
    {
        stateSubject.eraseToAnyPublisher()
    }

    public var currentState: RealtimeConnectionState {
        stateSubject.value
    }

    public var didReconnectPublisher: AnyPublisher<Void, Never> {
        didReconnectSubject.eraseToAnyPublisher()
    }

    init(
        transport: RealtimeTransportProtocol = SwiftStompTransport(),
        registry: RealtimeSubscriptionRegistry = RealtimeSubscriptionRegistry()
    ) {
        self.transport = transport
        self.registry = registry
        self.transport.delegate = self
    }

    public convenience init() {
        self.init(
            transport: SwiftStompTransport(),
            registry: RealtimeSubscriptionRegistry()
        )
    }

    public func connect(url: URL, authToken: String) async throws {
        guard !authToken.isEmpty else {
            let error = RealtimeError.authenticationRejected
            stateSubject.send(.failed(error))
            throw error
        }

        if currentState == .connected {
            return
        }

        try await withCheckedThrowingContinuation { continuation in
            connectionLock.lock()
            if currentState == .connected {
                connectionLock.unlock()
                continuation.resume()
                return
            }

            connectionWaiters.append(continuation)
            let shouldStartConnection = !isConnectionAttemptInFlight
            if shouldStartConnection {
                isConnectionAttemptInFlight = true
            }
            connectionLock.unlock()

            guard shouldStartConnection else { return }

            stateSubject.send(.connecting)
            scheduleConnectionTimeout()
            transport.autoReconnect = true

            let headers: [String: String] = [
                "Authorization": "Bearer \(authToken)",
                "passcode": authToken,
            ]

            transport.connect(url: url, headers: headers)
            transport.enableAutoPing(interval: 10)
        }
    }

    public func disconnect() async {
        failPendingConnection(with: .notConnected)
        transport.disconnect()
        registry.clear()
        stateSubject.send(.disconnected)
    }

    public func subscribe(topic: String) -> AnyPublisher<
        RealtimeEventEnvelope, Never
    > {
        let (publisher, _) = registry.register(topic: topic)
        if currentState == .connected {
            transport.subscribe(to: topic)
        }
        return publisher
    }

    public func stream(for topic: String) -> AsyncStream<RealtimeEventEnvelope>
    {
        let (_, stream) = registry.register(topic: topic)
        if currentState == .connected {
            transport.subscribe(to: topic)
        }
        return stream
    }

    public func unsubscribe(topic: String) {
        registry.unregister(topic: topic)
        if currentState == .connected {
            transport.unsubscribe(from: topic)
        }
    }

    // MARK: - RealtimeTransportDelegate

    func transportDidConnect(isReconnect: Bool) {
        let activeTopics = registry.activeTopics()
        for topic in activeTopics {
            transport.subscribe(to: topic)
        }

        if isReconnect {
            didReconnectSubject.send(())
        }

        stateSubject.send(.connected)
        finishPendingConnection()
    }

    func transportDidDisconnect(wasClean: Bool) {
        failPendingConnection(
            with: .connectionFailed(reason: "STOMP disconnected before connecting.")
        )
        if wasClean {
            stateSubject.send(.disconnected)
        } else {
            stateSubject.send(.reconnecting(attempt: 1))
        }
    }

    func transportDidReceiveMessage(
        destination: String,
        body: Any?,
        headers: [String: String]
    ) {
        do {
            let envelope = try RealtimeFrameDecoder.decode(
                body: body,
                headers: headers
            )
            registry.publish(envelope: envelope, to: destination)
        } catch {
            stateSubject.send(.failed(.malformedEnvelope))
        }
    }

    func transportDidEncounterError(description: String, isAuthError: Bool) {
        let error: RealtimeError = isAuthError
            ? .authenticationRejected
            : .transportError(description: description)
        stateSubject.send(.failed(error))
        failPendingConnection(with: error)
    }

    private func scheduleConnectionTimeout() {
        connectionTimeoutTask?.cancel()
        connectionTimeoutTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            guard !Task.isCancelled else { return }
            self?.failPendingConnection(
                with: .connectionFailed(reason: "Timed out waiting for STOMP to connect.")
            )
        }
    }

    private func finishPendingConnection() {
        connectionLock.lock()
        let waiters = connectionWaiters
        connectionWaiters.removeAll()
        isConnectionAttemptInFlight = false
        let timeoutTask = connectionTimeoutTask
        connectionTimeoutTask = nil
        connectionLock.unlock()

        timeoutTask?.cancel()
        waiters.forEach { $0.resume() }
    }

    private func failPendingConnection(with error: RealtimeError) {
        connectionLock.lock()
        let waiters = connectionWaiters
        connectionWaiters.removeAll()
        isConnectionAttemptInFlight = false
        let timeoutTask = connectionTimeoutTask
        connectionTimeoutTask = nil
        connectionLock.unlock()

        timeoutTask?.cancel()
        waiters.forEach { $0.resume(throwing: error) }
    }
}
