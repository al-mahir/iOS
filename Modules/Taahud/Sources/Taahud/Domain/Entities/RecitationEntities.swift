//
//  RecitationEntities.swift
//  Reading
//
//  Domain layer — pure Swift. No Foundation-heavy frameworks beyond what's
//  needed for basic value types (Foundation itself is fine; UIKit/SwiftUI/
//  SQLite3/URLSession are NOT allowed to leak in here).
//

import Foundation

// MARK: - Strictness / Engine / Rules

public enum RecitationStrictness: String, Codable, CaseIterable {
    case lenient
    case normal
    case strict
}

public enum RecitationEngine: String, Codable, CaseIterable {
    case real
    case zipformer
    case mock
}

/// Tajweed rule identifiers the client can opt into for a session.
/// Kept as raw strings passed straight through to the server, since the
/// authoritative rule set lives server-side and the client shouldn't need a
/// code change every time the server adds a rule.
public struct TajweedRule: RawRepresentable, Codable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let aaredMadd = TajweedRule(rawValue: "aared_madd")
    public static let ghonna = TajweedRule(rawValue: "ghonna")
    public static let qalqalah = TajweedRule(rawValue: "qalqalah")
    public static let ikhfa = TajweedRule(rawValue: "ikhfa")
    public static let idghaam = TajweedRule(rawValue: "idghaam")
}

// MARK: - Session

/// A single live recitation session against the AI engine.
public struct RecitationSession: Equatable {
    public let sessionId: String
    public let engine: RecitationEngine
    public let sampleRate: Int
    public var cursor: RecitationCursor

    public init(sessionId: String, engine: RecitationEngine, sampleRate: Int, cursor: RecitationCursor) {
        self.sessionId = sessionId
        self.engine = engine
        self.sampleRate = sampleRate
        self.cursor = cursor
    }
}

/// Position in the muṣḥaf the engine is currently tracking.
public struct RecitationCursor: Equatable, Codable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int

    public init(sura: Int, aya: Int, wordIdx: Int) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
}

// MARK: - Feedback

/// Grading status for a single word as returned by the engine.
///
/// Business rule (see API.md §3): `.almost` is a soft hint only — it must
/// never be rendered as a hard error and must never count toward an error
/// total. `.trimmed` means the word fell across an audio-chunk boundary and
/// must be rendered neutrally (no success or error indication at all).
public enum WordFeedbackStatus: String, Codable {
    case correct
    case error
    case almost
    case trimmed
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = WordFeedbackStatus(rawValue: raw) ?? .unknown
    }
}

/// Character-index bounds into the word's Uthmani text, used to highlight a
/// specific span (e.g. a single mistaken diacritic) rather than the whole word.
public struct UthmaniPosition: Equatable, Codable {
    public let start: Int
    public let end: Int

    public var range: Range<Int>? {
        guard start <= end, start >= 0 else { return nil }
        return start..<end
    }
}

/// A single Tajweed/Tashkeel/Hifz mistake attached to a word.
public struct TajweedError: Equatable, Codable, Identifiable {
    public var id: String { "\(rule)-\(position?.start ?? -1)-\(position?.end ?? -1)" }
    public let rule: String
    public let message: String
    public let position: UthmaniPosition?
}

/// Composite identity for a word within a recitation session. `wordIdx` alone
/// (position within its ayah) is not unique across a page or range that spans
/// more than one ayah, so anything keying UI state off feedback must use this
/// triple, not the bare `wordIdx`.
public struct RecitationWordKey: Hashable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int

    public init(sura: Int, aya: Int, wordIdx: Int) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
}

/// Feedback for one word of the target text, as tracked against the muṣḥaf.
public struct WordFeedback: Equatable, Identifiable {
    public var id: RecitationWordKey { key }
    public let wordIdx: Int
    public let sura: Int
    public let aya: Int
    public let status: WordFeedbackStatus
    public let trimmed: Bool
    public let uthmaniPosition: UthmaniPosition?
    public let errors: [TajweedError]

    public var key: RecitationWordKey { RecitationWordKey(sura: sura, aya: aya, wordIdx: wordIdx) }

    /// Whether this word should count toward the visible/hard error total.
    /// `.almost` is explicitly excluded per the strict business rule.
    public var countsAsHardError: Bool {
        status == .error
    }

    public init(wordIdx: Int, sura: Int, aya: Int, status: WordFeedbackStatus, trimmed: Bool,
                uthmaniPosition: UthmaniPosition?, errors: [TajweedError]) {
        self.wordIdx = wordIdx
        self.sura = sura
        self.aya = aya
        self.status = status
        self.trimmed = trimmed
        self.uthmaniPosition = uthmaniPosition
        self.errors = errors
    }
}

/// One pushed feedback event, covering a chunk of one or more words plus the
/// engine's updated cursor. `cursor` is nil when the server's `feedback.status`
/// was `ambiguous` or `no_match` — the engine is explicitly declining to
/// assert a position rather than guessing one (see API.md §5.5).
public struct RecitationFeedbackEvent: Equatable {
    public let chunkSeq: Int
    public let words: [WordFeedback]
    public let cursor: RecitationCursor?
}

// MARK: - Mushaf

/// A single word as laid out on a muṣḥaf page (KFGQPC v4 glyph data).
public struct AyahWord: Equatable, Identifiable {
    public let id: Int          // global word id (matches search-index.db word_idx pairing)
    public let sura: Int
    public let aya: Int
    public let wordPosition: Int
    public let text: String     // Uthmani text for accessibility / matching
    public let glyphCodePoint: String  // QPC v4 glyph string to render with the Mushaf font
    public let lineNumber: Int
    public let isVerseMarker: Bool
}

public struct MushafLine: Equatable, Identifiable {
    public let id: Int
    public let lineNumber: Int
    public let words: [AyahWord]
    public let isCentered: Bool
}

/// One rendered muṣḥaf page: line layout plus glyph data for rendering.
public struct MushafPageData: Equatable, Identifiable {
    public var id: Int { pageNumber }
    public let pageNumber: Int
    public let juz: Int
    public let lines: [MushafLine]

    public var words: [AyahWord] { lines.flatMap(\.words) }
}
