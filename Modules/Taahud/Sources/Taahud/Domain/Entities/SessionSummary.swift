import Foundation

/// A single reviewable mistake, flattened out of its parent feedback event so
/// the review screen (story 12) can list, filter and sort them independently
/// of chunking.
public struct MistakeRecord: Equatable, Identifiable, Sendable {
    public var id: String { "\(word.id)-\(error.id)" }
    public let word: WordFeedback
    public let error: RecognitionError
    public let occurredAt: MushafPosition
}

/// One thing worth reciting again (story 13).
public struct AyahRevisionSuggestion: Equatable, Identifiable, Sendable {
    public var id: String { "\(sura)-\(aya)" }
    public let sura: Int
    public let aya: Int
    public let mistakeCount: Int
}

/// A tajwīd/ṣifa rule that came up repeatedly (story 13).
public struct RuleRevisionSuggestion: Equatable, Identifiable, Sendable {
    public var id: String { ruleKeyOrName }
    public let ruleKeyOrName: String
    public let nameAr: String
    public let occurrences: Int
}

public struct RevisionPlan: Equatable, Sendable {
    public let ayahsToReview: [AyahRevisionSuggestion]
    public let rulesToReview: [RuleRevisionSuggestion]
    public let frequentMistakeDescriptions: [String]
}

/// The full result of a finished session (stories 11, 13, 14).
public struct SessionSummary: Equatable, Identifiable, Sendable {
    public let id: String // session_id
    public let startedAt: Date
    public let endedAt: Date
    public let engineUsed: ASREngine
    public let strictness: Strictness
    public let startPosition: MushafPosition?
    public let lastCursor: MushafPosition?

    public let totalWordsScored: Int
    public let correctWords: Int
    public let hintedWords: Int   // `almost`
    public let mistakeWords: Int  // `error`

    public let mistakes: [MistakeRecord]
    public let revisionPlan: RevisionPlan

    /// 0...1, based only on scored (non-trimmed) words.
    public var accuracy: Double {
        guard totalWordsScored > 0 else { return 0 }
        return Double(correctWords) / Double(totalWordsScored)
    }
}
