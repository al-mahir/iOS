//
//  RecitationWireMessages.swift
//  Taahud
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
    let cursor: CursorDTO?

    var domain: RecitationFeedbackEvent {
        RecitationFeedbackEvent(
            chunkSeq: chunk_seq,
            words: feedback.words.map(\.domain),
            cursor: cursor?.domain
        )
    }
}

struct ErrorMessageDTO: Decodable {
    let type: String
    let message: String
    let code: String?
}
