import Foundation

/// One tajwīd rule a finding touches (API.md §5.6).
public struct TajweedRuleMatch: Equatable, Sendable {
    public let nameAr: String
    public let nameEn: String
    public let goldenLen: Int?
    public let correctnessType: RuleCorrectnessType
    public let tag: String?
}

/// A single detected mistake on a word (API.md §5.6). `confidence == nil`
/// means unscored, not certain — it must grade as `almost` at every
/// strictness level, never as a hard error.
public struct RecognitionError: Equatable, Identifiable, Sendable {
    public var id: String { "\(errorType)-\(uthmaniRange.lowerBound)-\(uthmaniRange.upperBound)-\(speechErrorType)" }

    public let errorType: ErrorChannel
    public let speechErrorType: SpeechErrorType
    public let uthmaniRange: ClosedRange<Int>
    public let phRange: ClosedRange<Int>
    public let predPhRange: ClosedRange<Int>?
    public let expectedPh: String
    public let predictedPh: String
    public let expectedLen: Int?
    public let predictedLen: Int?
    public let tajweedRules: [TajweedRuleMatch]
    public let confidence: Double?
}

/// A single word's verdict within a feedback chunk (API.md §5.4 "A word").
public struct WordFeedback: Equatable, Identifiable, Sendable {
    public var id: String { "\(sura)-\(aya)-\(wordIdx)" }

    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let uthmani: String
    public let status: WordStatus
    public let errors: [RecognitionError]
    /// true = word sat on a chunk boundary and was NOT scored. Render neutral,
    /// never green/ticked, regardless of `status`.
    public let trimmed: Bool

    public var mushafPosition: MushafPosition { MushafPosition(sura: sura, aya: aya, wordIdx: wordIdx) }

    /// The rendering rule from API.md §5.5, in one place so every screen agrees:
    /// - trimmed        -> neutral, unscored
    /// - almost         -> hint, never a mistake, never scored
    /// - error          -> hard mistake
    /// - correct        -> tick
    public var displayState: WordDisplayState {
        if trimmed { return .unverified }
        switch status {
        case .correct: return .correct
        case .almost: return .hint
        case .error: return .mistake
        }
    }
}

public enum WordDisplayState: Sendable {
    case correct
    case hint
    case mistake
    case unverified
}

/// A candidate placement offered when `status == .ambiguous` (API.md §5.9).
public struct RecognitionCandidate: Equatable, Identifiable, Sendable {
    public var id: String { "\(sura)-\(aya)-\(wordIdx)" }
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let uthmaniText: String
    public let end: MushafPosition?
}

/// The graded result inside a feedback event (API.md §5.4 "The feedback object").
public struct FeedbackPayload: Equatable, Sendable {
    public let status: RecognitionStatus
    public let span: MushafPosition?
    public let end: MushafPosition?
    public let uthmaniText: String?
    public let predictedPhonemes: String
    public let referencePhonemes: String
    public let words: [WordFeedback]
    /// Populated only when status == .ambiguous. Never mark any word from these.
    public let candidates: [RecognitionCandidate]
    /// Recognised non-verse text (istiaatha/basmalah/sadaka). Acknowledge, never score.
    public let nonVerse: [NonVerseUtterance]
}

/// One event per finalized waqf chunk (API.md §5.4).
public struct FeedbackEvent: Equatable, Identifiable, Sendable {
    public var id: Int { chunkSeq }
    public let chunkSeq: Int
    public let audioSpanSec: ClosedRange<Double>
    public let forcedCut: Bool
    public let phonemes: String
    public let feedback: FeedbackPayload
    /// Resume point. Keep the last one seen; feed it into a reconnect `start`.
    public let cursor: MushafPosition?
}

/// Everything the transport can push during a live session.
///
/// `transportError` carries a description rather than `Error` itself: `Error`
/// does not refine `Sendable`, and this type has to cross from the socket's
/// background delivery into the `@MainActor` view model.
public enum SessionEvent: Sendable {
    case ack(SessionAck)
    case feedback(FeedbackEvent)
    case done
    /// Server closed the socket. `code` follows API.md §5.9 close-code table.
    case closed(code: Int, reason: String?)
    case transportError(String)
}
