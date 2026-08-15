//
//  RecitationRepositoryImpl.swift
//  Reading
//
//  Data layer. Translates between wire DTOs (RecitationWebSocketClient) and
//  Domain types (RecitationRepository protocol).
//

import Foundation

public final class RecitationRepositoryImpl: RecitationRepository {
    private let client: RecitationWebSocketClient

    /// - Parameters:
    ///   - webSocketURL: e.g. `wss://qualm-mountable-cultivate.ngrok-free.dev/ws/session`
    ///   - authToken: sent as the `token` header if the gateway requires it.
    public init(webSocketURL: URL, authToken: String?) {
        self.client = RecitationWebSocketClient(webSocketURL: webSocketURL, authToken: authToken)
    }

    public func startSession(config: RecitationStartConfig) async throws -> RecitationSession {
        let ack = try await client.connectAndHandshake(startMessage: StartMessageDTO(config: config))
        return RecitationSession(
            sessionId: ack.session_id,
            engine: RecitationEngine(rawValue: ack.engine ?? config.engine.rawValue) ?? config.engine,
            sampleRate: ack.sample_rate,
            cursor: RecitationCursor(sura: config.sura, aya: config.aya, wordIdx: config.wordIdx)
        )
    }

    public func feedbackEvents() -> AsyncThrowingStream<RecitationFeedbackEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task { [client] in
                do {
                    for try await event in client.events() {
                        switch event {
                        case .feedback(let feedback):
                            continuation.yield(feedback)
                        case .done:
                            continuation.finish()
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func sendAudioFrame(_ data: Data) async throws {
        try await client.sendAudioFrame(data)
    }

    public func seek(sura: Int, aya: Int, wordIdx: Int) async throws {
        try await client.sendSeek(sura: sura, aya: aya, wordIdx: wordIdx)
    }

    public func stopSession() async throws {
        try await client.sendEndAndAwaitDone()
        client.disconnect()
    }
}
