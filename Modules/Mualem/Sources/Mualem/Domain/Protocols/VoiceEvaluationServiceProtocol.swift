//
//  VoiceEvaluationServiceProtocol.swift
//  Mualem
//

import Foundation

public enum RecitationEvent {
    case wordDetected(wordIndex: Int)
    case completed(mistakes: [RecitationMistake])
    case error(Error)
}

public protocol VoiceEvaluationServiceProtocol {
    /// Simulates listening to the user and streaming real-time word detection events.
    /// - Parameters:
    ///   - surah: The surah number.
    ///   - ayah: The ayah number.
    ///   - simulatedDuration: How long to simulate listening before completing.
    /// - Returns: An AsyncStream of RecitationEvents.
    func evaluateStream(surah: Int, ayah: Int, simulatedDuration: TimeInterval) -> AsyncStream<RecitationEvent>
}
