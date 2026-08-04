//
//  RecitationWebSocketClient.swift
//  Reading


import Foundation

enum RecitationWebSocketError: LocalizedError {
    case notConnected
    case invalidHandshakeResponse
    case serverError(message: String, code: String?)
    case unexpectedFrameType

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "No active recitation session."
        case .invalidHandshakeResponse:
            return "The server did not acknowledge the session handshake."
        case .serverError(let message, let code):
            return "Recitation engine error\(code.map { " (\($0))" } ?? ""): \(message)"
        case .unexpectedFrameType:
            return "Received an unexpected frame type from the recitation engine."
        }
    }
}

/// Thin, protocol-faithful wrapper around `URLSessionWebSocketTask`.
/// Deliberately holds no domain knowledge — it moves JSON/binary frames in
/// and out and lets `RecitationRepositoryImpl` translate to/from Domain types.
final class RecitationWebSocketClient: NSObject {

    private let webSocketURL: URL
    private let authToken: String?
    private let urlSession: URLSession
    private var task: URLSessionWebSocketTask?

    init(webSocketURL: URL, authToken: String?, urlSession: URLSession = .init(configuration: .default)) {
        self.webSocketURL = webSocketURL
        self.authToken = authToken
        self.urlSession = urlSession
    }

    // MARK: Connection lifecycle

    /// Opens the socket and performs the JSON `start` handshake, returning
    /// the decoded session ack. Throws if the ack isn't the first frame back,
    /// which per the protocol means the server rejected the handshake.
    func connectAndHandshake(startMessage: StartMessageDTO) async throws -> SessionAckDTO {
        var request = URLRequest(url: webSocketURL)
        if let authToken {
            request.setValue(authToken, forHTTPHeaderField: "token")
        }

        let task = urlSession.webSocketTask(with: request)
        self.task = task
        task.resume()

        try await sendJSON(startMessage)

        let firstFrame = try await receiveRaw()
        switch firstFrame {
        case .string(let text):
            guard let data = text.data(using: .utf8) else {
                throw RecitationWebSocketError.invalidHandshakeResponse
            }
            let envelope = try JSONDecoder().decode(IncomingMessageEnvelopeDTO.self, from: data)
            if envelope.type == "error" {
                let err = try JSONDecoder().decode(ErrorMessageDTO.self, from: data)
                throw RecitationWebSocketError.serverError(message: err.message, code: err.code)
            }
            guard envelope.type == "session" else {
                throw RecitationWebSocketError.invalidHandshakeResponse
            }
            return try JSONDecoder().decode(SessionAckDTO.self, from: data)
        case .data:
            // Binary can never legitimately be the first frame back.
            throw RecitationWebSocketError.invalidHandshakeResponse
        @unknown default:
            throw RecitationWebSocketError.unexpectedFrameType
        }
    }

    /// Streams pushed JSON events (`feedback`, `done`, `error`) as an async
    /// sequence. Finishes normally on `done`; throws on `error` or a socket fault.
    func events() -> AsyncThrowingStream<IncomingRecitationEvent, Error> {
        AsyncThrowingStream { [weak self] continuation in
            let pump = Task { [weak self] in
                guard let self else { return }
                while true {
                    do {
                        let frame = try await self.receiveRaw()
                        guard case .string(let text) = frame, let data = text.data(using: .utf8) else {
                            continue // ignore stray binary frames from the server
                        }
                        let envelope = try JSONDecoder().decode(IncomingMessageEnvelopeDTO.self, from: data)
                        switch envelope.type {
                        case "feedback":
                            let event = try JSONDecoder().decode(FeedbackEventDTO.self, from: data)
                            continuation.yield(.feedback(event.domain))
                        case "done":
                            continuation.yield(.done)
                            continuation.finish()
                            return
                        case "error":
                            let err = try JSONDecoder().decode(ErrorMessageDTO.self, from: data)
                            continuation.finish(throwing: RecitationWebSocketError.serverError(message: err.message, code: err.code))
                            return
                        default:
                            // Forward-compatible: unknown frame types are ignored, not fatal.
                            continue
                        }
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
            }
            continuation.onTermination = { _ in pump.cancel() }
        }
    }

    // MARK: Sending

    func sendAudioFrame(_ data: Data) async throws {
        guard let task else { throw RecitationWebSocketError.notConnected }
        try await task.send(.data(data))
    }

    func sendSeek(sura: Int, aya: Int, wordIdx: Int) async throws {
        try await sendJSON(SeekMessageDTO(sura: sura, aya: aya, word_idx: wordIdx))
    }

    /// Sends `end` and awaits the matching `done` frame directly (not via
    /// `events()`, since the ViewModel's event consumer may already have
    /// finished iterating by the time stop() is called).
    func sendEndAndAwaitDone() async throws {
        guard task != nil else { return }
        try await sendJSON(EndMessageDTO())

        // Drain frames until `done` or the socket closes.
        while true {
            let frame = try await receiveRaw()
            guard case .string(let text) = frame, let data = text.data(using: .utf8) else { continue }
            let envelope = try JSONDecoder().decode(IncomingMessageEnvelopeDTO.self, from: data)
            if envelope.type == "done" {
                break
            }
        }
    }

    func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }

    // MARK: Private helpers

    private func sendJSON<T: Encodable>(_ payload: T) async throws {
        guard let task else { throw RecitationWebSocketError.notConnected }
        let data = try JSONEncoder().encode(payload)
        guard let text = String(data: data, encoding: .utf8) else {
            throw RecitationWebSocketError.invalidHandshakeResponse
        }
        try await task.send(.string(text))
    }

    private func receiveRaw() async throws -> URLSessionWebSocketTask.Message {
        guard let task else { throw RecitationWebSocketError.notConnected }
        return try await task.receive()
    }
}

enum IncomingRecitationEvent {
    case feedback(RecitationFeedbackEvent)
    case done
}
