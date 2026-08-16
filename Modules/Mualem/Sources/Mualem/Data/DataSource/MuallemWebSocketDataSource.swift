// MuallemWebSocketDataSource.swift
// Mualem

import Foundation

final class MuallemWebSocketDataSource: NSObject, @unchecked Sendable {
    private var task: URLSessionWebSocketTask?
    private var session: URLSession!
    private let encoder = JSONEncoder()
    private var continuation: AsyncStream<IncomingWSMessage>.Continuation?
    
    enum IncomingWSMessage: Sendable {
        case text(String)
        case closed(code: Int, reason: String?)
        case failure(String)
    }
    
    override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    }
    
    func connect(url: URL, token: String = MuallemSecrets.bearerToken) {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        task = session.webSocketTask(with: request)
        task?.resume()
    }
    
    func sendJSON<T: Encodable>(_ value: T) {
        guard let data = try? encoder.encode(value),
              let string = String(data: data, encoding: .utf8) else { return }
        let message = URLSessionWebSocketTask.Message.string(string)
        task?.send(message) { error in
            if let error = error {
                let failureMsg = String(
                    format: NSLocalizedString("ws_send_error", bundle: .module, value: "WebSocket send error: %@", comment: "WebSocket send failure message"),
                    error.localizedDescription
                )
                print(failureMsg)
            }
        }
    }
    
    func sendBinary(_ data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        task?.send(message) { error in
            if let error = error {
                let failureMsg = String(
                    format: NSLocalizedString("ws_binary_send_error", bundle: .module, value: "WebSocket binary send error: %@", comment: "WebSocket binary send failure message"),
                    error.localizedDescription
                )
                print(failureMsg)
            }
        }
    }
    
    /// Returns an AsyncStream of incoming messages and starts the receive loop.
    /// Must be called AFTER connect().
    func incomingMessages() -> AsyncStream<IncomingWSMessage> {
        return AsyncStream { continuation in
            self.continuation = continuation
            // Start the receive loop now that we have a continuation
            self.receiveMessage()
        }
    }
    
    func close() {
        task?.cancel(with: .normalClosure, reason: nil)
        continuation?.finish()
    }
    
    private func receiveMessage() {
        task?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.continuation?.yield(.text(text))
                case .data:
                    // Server doesn't send binary frames; ignore.
                    break
                @unknown default:
                    break
                }
                self.receiveMessage()
            case .failure(let error):
                let nsError = error as NSError
                let code = self.task?.closeCode.rawValue ?? URLSessionWebSocketTask.CloseCode.abnormalClosure.rawValue
                if code != URLSessionWebSocketTask.CloseCode.invalid.rawValue {
                    self.continuation?.yield(.closed(code: code, reason: nil))
                } else {
                    self.continuation?.yield(.failure(nsError.localizedDescription))
                }
                self.continuation?.finish()
            }
        }
    }
}
