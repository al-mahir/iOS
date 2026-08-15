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
    /// Listens to the user's recitation and streams real-time word detection events.
    /// - Parameters:
    ///   - surah: The surah number.
    ///   - ayah: The ayah number.
    ///   - expectedWords: The expected Ayah words (normalized Arabic, diacritics stripped) for live matching.
    ///   - maxDuration: Maximum listening time before auto-completing. Acts as a ceiling.
    /// - Returns: An AsyncStream of RecitationEvents.
    func evaluateStream(surah: Int, ayah: Int, expectedWords: [String], maxDuration: TimeInterval) -> AsyncStream<RecitationEvent>
}

/// Provides readable Arabic word text for a given Surah/Ayah.
/// Injected from the app layer since the Quran database lives in the main bundle.
public protocol AyahTextProviding {
    /// Returns the individual word texts (normalized, diacritics stripped) for the given Ayah, ordered by word position.
    func fetchNormalizedWords(surah: Int, ayah: Int) -> [String]
}
