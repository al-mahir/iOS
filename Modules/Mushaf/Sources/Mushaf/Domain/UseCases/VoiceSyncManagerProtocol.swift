//
//  VoiceSyncManagerProtocol.swift
//  Mushaf
//
//  Created for Mock Voice Reading Mode.
//

import Foundation

public protocol VoiceSyncManagerProtocol {
    /// A stream of the currently highlighted word key (format: "surah_ayah_position").
    /// Yields nil when stopped or when there is no active highlight.
    var highlightedWordKey: AsyncStream<String?> { get }
    
    /// Requests necessary permissions and starts listening.
    func startListening(targetSurah: Int, targetAyah: Int, targetText: String) async throws
    
    /// Stops the microphone and recognition task.
    func stopListening()
}
