// MuallemSessionRepositoryImpl.swift
// Mualem

import Foundation

final class MuallemSessionRepositoryImpl: MuallemSessionRepositoryProtocol {
    private let wsDataSource: MuallemWebSocketDataSource
    private let mockDataSource: MuallemMockDataSource
    private var usingMock = false
    
    var isConnected: Bool = false
    
    init(wsDataSource: MuallemWebSocketDataSource = MuallemWebSocketDataSource(),
         mockDataSource: MuallemMockDataSource = MuallemMockDataSource()) {
        self.wsDataSource = wsDataSource
        self.mockDataSource = mockDataSource
    }
    
    func startSession(config: MuallemWSSessionConfig) -> AsyncStream<MuallemSessionEvent> {
        let url = MuallemSecrets.webSocketURL
        
        wsDataSource.connect(url: url)
        self.isConnected = true
        self.usingMock = false
        
        let startMessage = StartMessageDTO(
            sura: config.sura,
            aya: config.aya,
            wordIdx: config.wordIdx,
            strictness: config.strictness.rawValue,
            engine: config.engine,
            rules: config.rules,
            moshaf: nil,
            includeUnits: false
        )
        wsDataSource.sendJSON(startMessage)
        
        let incoming = wsDataSource.incomingMessages()
        
        return AsyncStream { continuation in
            Task {
                var receivedData = false
                for await message in incoming {
                    switch message {
                    case .text(let jsonString):
                        if let data = jsonString.data(using: .utf8),
                           let dto = try? JSONDecoder().decode(WSIncomingMessageDTO.self, from: data) {
                            receivedData = true
                            switch dto {
                            case .sessionAck(let ack):
                                continuation.yield(FeedbackMapper.mapSessionAck(ack))
                            case .feedback(let fb):
                                continuation.yield(FeedbackMapper.mapFeedback(fb))
                            case .done:
                                continuation.yield(.done)
                            }
                        }
                    case .closed, .failure:
                        self.isConnected = false
                        if !receivedData {
                            self.usingMock = true
                            let mockStream = self.mockDataSource.simulateSession(config: config)
                            for await mockEvent in mockStream {
                                continuation.yield(mockEvent)
                            }
                        }
                        continuation.finish()
                    }
                }
                continuation.finish()
            }
        }
    }
    
    func sendAudio(_ data: Data) {
        if !usingMock && isConnected {
            wsDataSource.sendBinary(data)
        }
    }
    
    func seek(sura: Int, aya: Int, wordIdx: Int) {
        if !usingMock && isConnected {
            let msg = SeekMessageDTO(sura: sura, aya: aya, wordIdx: wordIdx)
            wsDataSource.sendJSON(msg)
        }
    }
    
    func endSession() {
        if !usingMock && isConnected {
            let msg = EndMessageDTO()
            wsDataSource.sendJSON(msg)
            wsDataSource.close()
        } else if usingMock {
            mockDataSource.finishMockSession()
        }
        isConnected = false
    }
}
