import Foundation

final class RecitationSessionRepositoryImpl: RecitationSessionRepository, @unchecked Sendable {
    private let socket: RecitationSocketConnecting
    private let audio: AudioCapturing
    private let wsURL: URL

    init(socket: RecitationSocketConnecting, audio: AudioCapturing, wsURL: URL) {
        self.socket = socket
        self.audio = audio
        self.wsURL = wsURL
    }

    func connect(config: TaahudSessionConfig) async throws -> AsyncStream<SessionEvent> {
        socket.connect(url: wsURL)

        let stream = AsyncStream<SessionEvent> { continuation in
            let task = Task {
                let decoder = JSONDecoder()
                for await message in self.socket.incomingMessages() {
                    switch message {
                    case .text(let text):
                        guard let event = Self.decode(text, decoder: decoder) else { continue }
                        continuation.yield(event)
                        if case .done = event { continuation.finish() }
                    case .closed(let code, let reason):
                        continuation.yield(.closed(code: code, reason: reason))
                        continuation.finish()
                    case .failure(let description):
                        continuation.yield(.transportError(description))
                        continuation.finish()
                    }
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }

        // The JSON `start` message must be the very first frame (API.md §5.1).
        socket.sendJSON(StartMessageDTO(config: config))

        audio.onPCMFrame = { [weak self] data in
            self?.socket.sendBinary(data)
        }
        try audio.start()

        return stream
    }

    func pauseCapture() {
        audio.pause()
    }

    func resumeCapture() throws {
        try audio.resume()
    }

    func seek(to position: MushafPosition) {
        socket.sendJSON(SeekMessageDTO(position: position))
    }

    func end() {
        audio.stop()
        socket.sendJSON(EndMessageDTO())
    }

    func disconnect() {
        audio.stop()
        socket.close()
    }

    private static func decode(_ text: String, decoder: JSONDecoder) -> SessionEvent? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let type = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["type"] as? String else {
            return nil
        }
        switch type {
        case "session":
            guard let dto = try? decoder.decode(SessionAckDTO.self, from: data) else { return nil }
            return .ack(dto.toDomain())
        case "feedback":
            guard let dto = try? decoder.decode(FeedbackEventDTO.self, from: data) else { return nil }
            return .feedback(dto.toDomain())
        case "done":
            return .done
        default:
            return nil
        }
    }
}
