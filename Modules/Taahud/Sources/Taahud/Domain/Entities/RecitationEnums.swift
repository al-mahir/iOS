import Foundation

/// ASR engine choice. Mirrors `available_engines` from GET /health.
public enum ASREngine: String, Codable, CaseIterable, Sendable {
    case real
    case zipformer
    case mock
}

/// Confidence threshold profile for a session. Does not change what counts as
/// a mistake — only the model-confidence bar at which a finding becomes a hard
/// `error` instead of `almost`. Lower threshold = harsher teacher.
public enum Strictness: String, Codable, CaseIterable, Sendable {
    case lenient
    case normal
    case strict
}

/// Per-word verdict. `almost` is NOT a soft error — render as a hint only,
/// never in the mistakes list, never scored against the reciter.
public enum WordStatus: String, Codable, Sendable {
    case correct
    case almost
    case error
}

/// Whether the server could place the recited chunk in the muṣḥaf.
public enum RecognitionStatus: String, Codable, Sendable {
    case ok
    case ambiguous
    case noMatch = "no_match"
}

/// Which grading channel a finding belongs to.
public enum ErrorChannel: String, Codable, Sendable {
    case tajweed
    case normal   // ḥifẓ: wrong or missing word
    case tashkeel
    case sifa
}

/// What the reciter actually did, relative to the reference.
public enum SpeechErrorType: String, Codable, Sendable {
    case insert
    case delete
    case replace
}

/// Recognised non-verse utterances the server reports but never scores.
public enum NonVerseUtterance: String, Codable, Sendable {
    case istiaatha
    case basmalah
    case sadaka
}

/// `correctness_type` on a tajwīd rule match.
public enum RuleCorrectnessType: String, Codable, Sendable {
    case match
    case count
}
