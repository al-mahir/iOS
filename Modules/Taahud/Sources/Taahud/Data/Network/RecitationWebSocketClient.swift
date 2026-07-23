import Foundation

enum IncomingSocketMessage: Sendable {
    case text(String)
    case closed(code: Int, reason: String?)
    /// A description, not the raw `Error` — `Error` isn't `Sendable`, and
    /// this crosses from `URLSession`'s delegate queue into our own stream.
    case failure(String)
}

/// Thin transport wrapper. Knows nothing about the recitation domain — just
/// JSON-first-frame semantics and binary audio frames, per API.md §5.1/§5.3.
protocol RecitationSocketConnecting: AnyObject, Sendable {
    func connect(url: URL)
    /// The very first send after connect MUST be this; a non-JSON first frame
    /// gets the socket closed by the server with code 1002.
    func sendJSON<T: Encodable>(_ value: T)
    func sendBinary(_ data: Data)
    func incomingMessages() -> AsyncStream<IncomingSocketMessage>
    func close()
}

final class RecitationWebSocketClient: NSObject, RecitationSocketConnecting, @unchecked Sendable {
    private var task: URLSessionWebSocketTask?
    private var session: URLSession!
    private let encoder = JSONEncoder()
    private var continuation: AsyncStream<IncomingSocketMessage>.Continuation?

    override init() {
        super.init()
        session = URLSession(configuration: .default)
    }

    func connect(url: URL) {
        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()
        receiveLoop()
    }

    func sendJSON<T: Encodable>(_ value: T) {
        guard let data = try? encoder.encode(value), let text = String(data: data, encoding: .utf8) else { return }
        task?.send(.string(text)) { [weak self] error in
            if let error { self?.continuation?.yield(.failure(error.localizedDescription)) }
        }
    }

    func sendBinary(_ data: Data) {
        // Always a binary frame, per API.md §5.3 — a text/base64 frame is a
        // documented "common mistake" that silently produces nothing.
        task?.send(.data(data)) { [weak self] error in
            if let error { self?.continuation?.yield(.failure(error.localizedDescription)) }
        }
    }

    func incomingMessages() -> AsyncStream<IncomingSocketMessage> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }

    func close() {
        task?.cancel(with: .normalClosure, reason: nil)
        continuation?.finish()
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.string(let text)):
                self.continuation?.yield(.text(text))
                self.receiveLoop()
            case .success(.data):
                // Server never sends binary; ignore and keep listening rather
                // than tearing down the session over an unexpected frame.
                self.receiveLoop()
            case .success:
                self.receiveLoop()
            case .failure(let error):
                let nsError = error as NSError
                let code = self.task?.closeCode.rawValue ?? URLSessionWebSocketTask.CloseCode.abnormalClosure.rawValue
                if code != URLSessionWebSocketTask.CloseCode.invalid.rawValue {
                    self.continuation?.yield(.closed(code: code, reason: self.reasonString()))
                } else {
                    self.continuation?.yield(.failure(nsError.localizedDescription))
                }
                self.continuation?.finish()
            }
        }
    }

    private func reasonString() -> String? {
        guard let data = task?.closeReason else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
