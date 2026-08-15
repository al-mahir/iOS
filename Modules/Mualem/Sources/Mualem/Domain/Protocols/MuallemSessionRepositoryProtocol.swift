//
//  MuallemSessionRepositoryProtocol.swift
//  Mualem
//
//  Domain contract for the AI WebSocket recitation session.
//

import Foundation

public protocol MuallemSessionRepositoryProtocol {
    /// Opens a WebSocket session and returns an AsyncStream of feedback events.
    /// The stream emits sessionAck, feedback events, and a final done event.
    func startSession(config: MuallemWSSessionConfig) -> AsyncStream<MuallemSessionEvent>
    
    /// Sends raw 16 kHz mono PCM16-LE audio bytes.
    func sendAudio(_ data: Data)
    
    /// Sends a seek command when the user repositions in the muṣḥaf.
    func seek(sura: Int, aya: Int, wordIdx: Int)
    
    /// Ends the session gracefully and waits for the final flush.
    func endSession()
    
    /// Whether the WebSocket is currently connected.
    var isConnected: Bool { get }
}
