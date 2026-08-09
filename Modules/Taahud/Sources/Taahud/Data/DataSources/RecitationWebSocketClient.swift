//
//  RecitationWebSocketClient.swift
//  Taahud


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
    func connectAndHandshake(startMessage: StartMessageDTO) async throws -> SessionAckDTO {
        var request = URLRequest(url: webSocketURL)
        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("1", forHTTPHeaderField: "ngrok-skip-browser-warning")

        let task = urlSession.webSocketTask(with: request)
        self.task = task
        task.resume()
        print("🔌 [Taahud/WS] connecting to \(webSocketURL.absoluteString)")

        try await sendJSON(startMessage)

        let firstFrame = try await receiveRaw()
        switch firstFrame {
        case .string(let text):
            print("📥 [Taahud/WS] handshake response ← \(text)")
            guard let data = text.data(using: .utf8) else {
                throw RecitationWebSocketError.invalidHandshakeResponse
            }
            let envelope = try JSONDecoder().decode(IncomingMessageEnvelopeDTO.self, from: data)
            if envelope.type == "error" {
                let err = try JSONDecoder().decode(ErrorMessageDTO.self, from: data)
                print("❌ [Taahud/WS] server rejected handshake: \(err.message) (code: \(err.code ?? "none"))")
                throw RecitationWebSocketError.serverError(message: err.message, code: err.code)
            }
            guard envelope.type == "session" else {
                print("❌ [Taahud/WS] unexpected first frame type: \(envelope.type)")
                throw RecitationWebSocketError.invalidHandshakeResponse
            }
            let ack = try JSONDecoder().decode(SessionAckDTO.self, from: data)
            print("✅ [Taahud/WS] session started: id=\(ack.session_id) engine=\(ack.engine ?? "?") sampleRate=\(ack.sample_rate)")
            return ack
        case .data:
            throw RecitationWebSocketError.invalidHandshakeResponse
        @unknown default:
            throw RecitationWebSocketError.unexpectedFrameType
        }
    }

    func events() -> AsyncThrowingStream<IncomingRecitationEvent, Error> {
        AsyncThrowingStream { [weak self] continuation in
            let pump = Task { [weak self] in
                guard let self else { return }
                while true {
                    do {
                        let frame = try await self.receiveRaw()
                        guard case .string(let text) = frame, let data = text.data(using: .utf8) else {
                            continue
                        }
                        let envelope = try JSONDecoder().decode(IncomingMessageEnvelopeDTO.self, from: data)
                        switch envelope.type {
                        case "feedback":
                            let event = try JSONDecoder().decode(FeedbackEventDTO.self, from: data)
                            let statuses = event.feedback.words.map { "\($0.sura):\($0.aya):\($0.word_idx)=\($0.status)" }.joined(separator: ", ")
                            print("📥 [Taahud/WS] feedback ← chunk #\(event.chunk_seq) cursor=(\(event.cursor.sura):\(event.cursor.aya):\(event.cursor.word_idx)) words=[\(statuses)]")
                            continuation.yield(.feedback(event.domain))
                        case "done":
                            print("📥 [Taahud/WS] done ← server flushed and closed the session")
                            continuation.yield(.done)
                            continuation.finish()
                            return
                        case "error":
                            let err = try JSONDecoder().decode(ErrorMessageDTO.self, from: data)
                            print("❌ [Taahud/WS] error ← \(err.message) (code: \(err.code ?? "none"))")
                            continuation.finish(throwing: RecitationWebSocketError.serverError(message: err.message, code: err.code))
                            return
                        default:
                            print("📥 [Taahud/WS] ignoring unrecognized frame type: \(envelope.type)")
                            continue
                        }
                    } catch {
                        print("❌ [Taahud/WS] events() stream error: \(error.localizedDescription)")
                        continuation.finish(throwing: error)
                        return
                    }
                }
            }
            continuation.onTermination = { _ in pump.cancel() }
        }
    }

    // MARK: Sending

    private var sentFrameCount = 0
    private var sentByteTotal = 0
    
    func sendAudioFrame(_ data: Data) async throws {
        guard let task else { throw RecitationWebSocketError.notConnected }
        try await task.send(.data(data))
        sentFrameCount += 1
        sentByteTotal += data.count
        if sentFrameCount % 10 == 0 {
            print("📤 [Taahud/WS] audio → sent \(sentFrameCount) frames (\(sentByteTotal) bytes total, last frame \(data.count) bytes)")
        }
    }

    func sendSeek(sura: Int, aya: Int, wordIdx: Int) async throws {
        try await sendJSON(SeekMessageDTO(sura: sura, aya: aya, word_idx: wordIdx))
    }

    func sendEndAndAwaitDone() async throws {
        guard task != nil else { return }
        try await sendJSON(EndMessageDTO())

        while true {
            let frame = try await receiveRaw()
            guard case .string(let text) = frame, let data = text.data(using: .utf8) else { continue }
            print("📥 [Taahud/WS] draining on stop ← \(text)")
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
        print("📤 [Taahud/WS] sending → \(text)")
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
