//
//  WordTiming.swift
//  Listening
//

import Foundation

/// Represents the exact playback time window for a single word in the Quran.
/// Used by the AudioSyncManager to publish the currently highlighted word.
public struct WordTiming: Hashable, Sendable {
    public let surah: Int
    public let ayah: Int
    public let wordPosition: Int  // 1-based index within the ayah
    public let startMs: Int       // start time in milliseconds
    public let endMs: Int         // end time in milliseconds

    public init(
        surah: Int,
        ayah: Int,
        wordPosition: Int,
        startMs: Int,
        endMs: Int
    ) {
        self.surah = surah
        self.ayah = ayah
        self.wordPosition = wordPosition
        self.startMs = startMs
        self.endMs = endMs
    }

    /// Unique key matching the format used in `QuranWord` for highlight lookup
    /// Format: "surah:ayah:wordPosition"
    public var wordKey: String {
        "\(surah):\(ayah):\(wordPosition)"
    }

    /// Check if a given time (in milliseconds) falls within this word's window
    public func contains(ms: Int) -> Bool {
        ms >= startMs && ms < endMs
    }
}
