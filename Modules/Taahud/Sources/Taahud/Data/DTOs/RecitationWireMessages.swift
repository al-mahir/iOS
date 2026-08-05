//
//  RecitationWireMessages.swift
//  Reading
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

struct UthmaniPositionDTO: Decodable {
    let start: Int
    let end: Int

    var domain: UthmaniPosition {
        UthmaniPosition(start: start, end: end)
    }
}

struct TajweedErrorDTO: Decodable {
    let rule: String
    let message: String
    let uthmani_pos: UthmaniPositionDTO?

    var domain: TajweedError {
        TajweedError(rule: rule, message: message, position: uthmani_pos?.domain)
    }
}

struct WordFeedbackDTO: Decodable {
    let word_idx: Int
    let sura: Int
    let aya: Int
    let status: String
    let trimmed: Bool?
    let uthmani_pos: UthmaniPositionDTO?
    let errors: [TajweedErrorDTO]?

    var domain: WordFeedback {
        WordFeedback(
            wordIdx: word_idx,
            sura: sura,
            aya: aya,
            status: WordFeedbackStatus(rawValue: status) ?? .unknown,
            trimmed: trimmed ?? false,
            uthmaniPosition: uthmani_pos?.domain,
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
    let cursor: CursorDTO

    var domain: RecitationFeedbackEvent {
        RecitationFeedbackEvent(
            chunkSeq: chunk_seq,
            words: feedback.words.map(\.domain),
            cursor: cursor.domain
        )
    }
}

/// Server-pushed error frame, e.g. malformed audio or an engine fault mid-session.
struct ErrorMessageDTO: Decodable {
    let type: String
    let message: String
    let code: String?
}
