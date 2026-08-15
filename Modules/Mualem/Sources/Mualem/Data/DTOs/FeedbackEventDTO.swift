// FeedbackEventDTO.swift
// Mualem

import Foundation

enum WSIncomingMessageDTO: Decodable {
    case sessionAck(SessionAckDTO)
    case feedback(FeedbackEventDTO)
    case done
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "session":
            let ack = try SessionAckDTO(from: decoder)
            self = .sessionAck(ack)
        case "feedback":
            let feedback = try FeedbackEventDTO(from: decoder)
            self = .feedback(feedback)
        case "done":
            self = .done
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown message type: \(type)")
        }
    }
}

struct SessionAckDTO: Decodable {
    let sessionId: String
    let engine: String
    let sampleRate: Int
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case engine
        case sampleRate = "sample_rate"
    }
}

struct FeedbackEventDTO: Decodable {
    let chunkSeq: Int
    let audioSpanSec: [Double]
    let forcedCut: Bool
    let phonemes: String?
    let feedback: FeedbackPayloadDTO
    let cursor: PositionDTO?
    
    enum CodingKeys: String, CodingKey {
        case chunkSeq = "chunk_seq"
        case audioSpanSec = "audio_span_sec"
        case forcedCut = "forced_cut"
        case phonemes
        case feedback
        case cursor
    }
}

struct FeedbackPayloadDTO: Decodable {
    let status: String
    let span: PositionDTO?
    let end: PositionDTO?
    let uthmaniText: String?
    let predictedPhonemes: String?
    let referencePhonemes: String?
    let words: [WordFeedbackDTO]
    let candidates: [CandidateDTO]?
    let nonVerse: [String]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case span
        case end
        case uthmaniText = "uthmani_text"
        case predictedPhonemes = "predicted_phonemes"
        case referencePhonemes = "reference_phonemes"
        case words
        case candidates
        case nonVerse = "non_verse"
    }
}

struct WordFeedbackDTO: Decodable {
    let sura: Int
    let aya: Int
    let wordIdx: Int
    let uthmani: String
    let status: String
    let trimmed: Bool
    let errors: [WordErrorDTO]
    
    enum CodingKeys: String, CodingKey {
        case sura
        case aya
        case wordIdx = "word_idx"
        case uthmani
        case status
        case trimmed
        case errors
    }
}

struct WordErrorDTO: Decodable {
    let errorType: String
    let speechErrorType: String?
    let uthmaniPos: [Int]?
    let phPos: [Int]?
    let predPhPos: [Int]?
    let expectedPh: String?
    let predictedPh: String?
    let expectedLen: Int?
    let predictedLen: Int?
    let tajweedRules: [TajweedRuleMatchDTO]?
    let confidence: Double?
    
    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
        case speechErrorType = "speech_error_type"
        case uthmaniPos = "uthmani_pos"
        case phPos = "ph_pos"
        case predPhPos = "pred_ph_pos"
        case expectedPh = "expected_ph"
        case predictedPh = "predicted_ph"
        case expectedLen = "expected_len"
        case predictedLen = "predicted_len"
        case tajweedRules = "tajweed_rules"
        case confidence
    }
}

struct TajweedRuleMatchDTO: Decodable {
    let nameAr: String
    let nameEn: String
    let goldenLen: Int?
    let correctnessType: String?
    let tag: String?
    
    enum CodingKeys: String, CodingKey {
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case goldenLen = "golden_len"
        case correctnessType = "correctness_type"
        case tag
    }
}

struct PositionDTO: Decodable {
    let sura: Int
    let aya: Int
    let wordIdx: Int
    
    enum CodingKeys: String, CodingKey {
        case sura
        case aya
        case wordIdx = "word_idx"
    }
}

struct CandidateDTO: Decodable {
    let sura: Int
    let aya: Int
    let wordIdx: Int
    let uthmaniText: String
    let end: PositionDTO?
    
    enum CodingKeys: String, CodingKey {
        case sura
        case aya
        case wordIdx = "word_idx"
        case uthmaniText = "uthmani_text"
        case end
    }
}
