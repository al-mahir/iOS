//
//  RealtimeSubscriptionRegistry.swift
//  RealtimeKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import Combine

final class RealtimeSubscriptionEntry: @unchecked Sendable {
    let topic: String
    let subject = PassthroughSubject<RealtimeEventEnvelope, Never>()
    var continuation: AsyncStream<RealtimeEventEnvelope>.Continuation?

    init(topic: String) {
        self.topic = topic
    }
}

final class RealtimeSubscriptionRegistry: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [String: RealtimeSubscriptionEntry] = [:]

    init() {}

    func register(topic: String) -> (publisher: AnyPublisher<RealtimeEventEnvelope, Never>, stream: AsyncStream<RealtimeEventEnvelope>) {
        lock.lock()
        defer { lock.unlock() }

        if let existing = entries[topic] {
            let stream = AsyncStream<RealtimeEventEnvelope> { continuation in
                existing.continuation = continuation
            }
            return (existing.subject.eraseToAnyPublisher(), stream)
        }

        let entry = RealtimeSubscriptionEntry(topic: topic)
        var streamContinuation: AsyncStream<RealtimeEventEnvelope>.Continuation?
        let stream = AsyncStream<RealtimeEventEnvelope> { continuation in
            streamContinuation = continuation
        }
        entry.continuation = streamContinuation
        entries[topic] = entry

        return (entry.subject.eraseToAnyPublisher(), stream)
    }

    func unregister(topic: String) {
        lock.lock()
        let entry = entries.removeValue(forKey: topic)
        lock.unlock()

        entry?.subject.send(completion: .finished)
        entry?.continuation?.finish()
    }

    func publish(envelope: RealtimeEventEnvelope, to topic: String) {
        lock.lock()
        let entry = entries[topic]
        lock.unlock()

        entry?.subject.send(envelope)
        entry?.continuation?.yield(envelope)
    }

    func activeTopics() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entries.keys)
    }

    func clear() {
        lock.lock()
        let currentEntries = entries
        entries.removeAll()
        lock.unlock()

        for entry in currentEntries.values {
            entry.subject.send(completion: .finished)
            entry.continuation?.finish()
        }
    }
}
