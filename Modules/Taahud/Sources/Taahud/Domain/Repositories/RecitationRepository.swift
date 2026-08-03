//
//  RecitationRepository.swift
//  Reading
//
//  Domain layer contract. No networking types leak through this boundary —
//  the Data layer implementation owns URLSessionWebSocketTask entirely.
//

import Foundation

/// Configuration for starting a live recitation session.
public struct RecitationStartConfig: Equatable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let strictness: RecitationStrictness
    public let engine: RecitationEngine
    public let rules: [TajweedRule]

    public init(sura: Int, aya: Int, wordIdx: Int,
                strictness: RecitationStrictness = .normal,
                engine: RecitationEngine = .real,
                rules: [TajweedRule] = [.aaredMadd, .ghonna]) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
        self.strictness = strictness
        self.engine = engine
        self.rules = rules
    }
}

/// Contract for talking to the live AI recitation engine over its WebSocket
/// protocol. Implementations are responsible for the handshake, streaming
/// binary audio frames, and surfacing pushed feedback/teardown events.
public protocol RecitationRepository {

    /// Opens the socket, performs the JSON `start` handshake, and returns the
    /// resulting session once the `session` ack frame is received.
    func startSession(config: RecitationStartConfig) async throws -> RecitationSession

    /// A continuous stream of feedback events pushed by the server for the
    /// currently open session. Ends (without throwing) once `done` is received
    /// after `stopSession()`, or throws if the socket errors/closes unexpectedly.
    func feedbackEvents() -> AsyncThrowingStream<RecitationFeedbackEvent, Error>

    /// Streams a single raw PCM16 mono 16kHz binary frame (~100ms / 3200 bytes)
    /// to the server. Caller (ProcessAudioStreamUseCase) is responsible for
    /// chunking; this just forwards the frame.
    func sendAudioFrame(_ data: Data) async throws

    /// Sends a `seek` message when the user jumps to a different word/ayah,
    /// e.g. by turning a page or tapping directly on an ayah.
    func seek(sura: Int, aya: Int, wordIdx: Int) async throws

    /// Sends `end`, waits for the `done` ack, then closes the socket.
    func stopSession() async throws
}
