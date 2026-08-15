//
//  RecitationWireMessages.swift
//  Taahud
//
//  Data layer — Codable wire-format structs for the /ws/session protocol
//  (see API.md). These are intentionally separate from the Domain entities:
//  the wire shape is allowed to change without touching Domain, and Domain
//  is allowed to have a friendlier shape than the JSON does.
//

import Foundation

// MARK: - Outgoing

struct StartMessageDTO: Encodable {
    let type = "start"
    let sura: Int
    let aya: Int
    let word_idx: Int
    let strictness: String
    let engine: String
    let rules: [String]

    init(config: RecitationStartConfig) {
        self.sura = config.sura
        self.aya = config.aya
        self.word_idx = config.wordIdx
        self.strictness = config.strictness.rawValue
        self.engine = config.engine.rawValue
        self.rules = config.rules.map(\.rawValue)
    }
}

struct SeekMessageDTO: Encodable {
    let type = "seek"
    let sura: Int
    let aya: Int
    let word_idx: Int
}

struct EndMessageDTO: Encodable {
    let type = "end"
}

// MARK: - Incoming

/// Every incoming text frame carries a `type` discriminator. We decode it
/// generically first, then decode the full payload once we know which case
/// we're in — `JSONDecoder` doesn't do discriminated unions natively.
struct IncomingMessageEnvelopeDTO: Decodable {
    let type: String
}

struct SessionAckDTO: Decodable {
    let type: String
    let session_id: String
    let sample_rate: Int
    let engine: String?
}

struct DoneMessageDTO: Decodable {
    let type: String
}

struct CursorDTO: Decodable {
    let sura: Int
    let aya: Int
    let word_idx: Int

    var domain: RecitationCursor {
        RecitationCursor(sura: sura, aya: aya, wordIdx: word_idx)
    }
}

struct UthmaniPositionDTO {
    /// `uthmani_pos` (and `ph_pos`/`pred_ph_pos`) arrive on the wire as a
    /// plain two-element array `[start, end]`, not an object — there is no
    /// `{"start":...,"end":...}` shape anywhere in the protocol.
    static func domain(from pair: [Int]?) -> UthmaniPosition? {
        guard let pair, pair.count == 2 else { return nil }
        return UthmaniPosition(start: pair[0], end: pair[1])
    }
}

struct TajweedRuleInfoDTO: Decodable {
    let name_ar: String
    let name_en: String
    let golden_len: Int?
    let correctness_type: String?
    let tag: String?

    var domain: TajweedError.RuleInfo {
        TajweedError.RuleInfo(
            nameAr: name_ar, nameEn: name_en,
            goldenLen: golden_len, correctnessType: correctness_type, tag: tag
        )
    }
}

struct TajweedErrorDTO: Decodable {
    let error_type: String
    let speech_error_type: String?
    let uthmani_pos: [Int]?
    let expected_ph: String?
    let predicted_ph: String?
    let expected_len: Int?
    let predicted_len: Int?
    let tajweed_rules: [TajweedRuleInfoDTO]?
    let confidence: Double?

    var domain: TajweedError {
        TajweedError(
            errorType: TajweedError.ErrorType(rawValue: error_type) ?? .unknown,
            speechErrorType: speech_error_type.flatMap(TajweedError.SpeechErrorType.init(rawValue:)),
            position: UthmaniPositionDTO.domain(from: uthmani_pos),
            expectedPh: expected_ph ?? "",
            predictedPh: predicted_ph ?? "",
            expectedLen: expected_len,
            predictedLen: predicted_len,
            tajweedRules: (tajweed_rules ?? []).map(\.domain),
            confidence: confidence
        )
    }
}

struct WordFeedbackDTO: Decodable {
    let word_idx: Int
    let sura: Int
    let aya: Int
    let status: String
    let trimmed: Bool?
    let errors: [TajweedErrorDTO]?

    var domain: WordFeedback {
        WordFeedback(
            wordIdx: word_idx,
            sura: sura,
            aya: aya,
            status: WordFeedbackStatus(rawValue: status) ?? .unknown,
            trimmed: trimmed ?? false,
            uthmaniPosition: nil,
            errors: (errors ?? []).map(\.domain)
        )
    }
}

struct FeedbackPayloadDTO: Decodable {
    let status: String
    let words: [WordFeedbackDTO]
}

struct FeedbackEventDTO: Decodable {
    let type: String
    let chunk_seq: Int
    let feedback: FeedbackPayloadDTO
    // Nullable per API.md §5.4: "cursor | object or null | Where the reciter
    // now is." It's null exactly when `feedback.status` is `ambiguous` or
    // `no_match` — the engine declining to assert a position rather than
    // guessing one (API.md §5.5). Decoding this as non-optional is what was
    // crashing the event stream.
    let cursor: CursorDTO?

    var domain: RecitationFeedbackEvent {
        RecitationFeedbackEvent(
            chunkSeq: chunk_seq,
            words: feedback.words.map(\.domain),
            cursor: cursor?.domain
        )
    }
}

/// Server-pushed error frame, e.g. malformed audio or an engine fault mid-session.
struct ErrorMessageDTO: Decodable {
    let type: String
    let message: String
    let code: String?
}
