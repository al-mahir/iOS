//
//  StartMuallemSessionUseCase.swift
//  Mualem
//
//  Orchestrates opening a WebSocket session with the AI service.
//

import Foundation

public final class StartMuallemSessionUseCase {
    private let repository: MuallemSessionRepositoryProtocol
    
    public init(repository: MuallemSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Opens a WS session and returns a stream of events.
    public func execute(config: MuallemWSSessionConfig) -> AsyncStream<MuallemSessionEvent> {
        return repository.startSession(config: config)
    }
    
    /// Sends raw PCM16 audio data to the session.
    public func sendAudio(_ data: Data) {
        repository.sendAudio(data)
    }
    
    /// Repositions the cursor.
    public func seek(sura: Int, aya: Int, wordIdx: Int) {
        repository.seek(sura: sura, aya: aya, wordIdx: wordIdx)
    }
    
    /// Ends the session.
    public func endSession() {
        repository.endSession()
    }
    
    public var isConnected: Bool {
        repository.isConnected
    }
}
