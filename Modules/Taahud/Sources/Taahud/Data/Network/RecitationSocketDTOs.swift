import Foundation

// MARK: - Outgoing (client -> server), API.md §5.2 / §5.7 / §5.8

struct StartMessageDTO: Encodable {
    let type = "start"
    let sura: Int?
    let aya: Int?
    let word_idx: Int?
    let strictness: String
    let engine: String?
    let rules: [String]?
    let moshaf: [String: AnyEncodable]?
    let include_units: Bool

    init(config: TaahudSessionConfig) {
        sura = config.position?.sura
        aya = config.position?.aya
        word_idx = config.position?.wordIdx
        strictness = config.strictness.rawValue
        engine = config.engine?.rawValue
        rules = config.rules
        moshaf = config.moshafOverrides.isEmpty ? nil : config.moshafOverrides.mapValues {
            switch $0 {
            case .string(let s): return AnyEncodable(s)
            case .int(let i): return AnyEncodable(i)
            }
        }
        include_units = config.includeUnits
    }
}

struct SeekMessageDTO: Encodable {
    let type = "seek"
    let sura: Int
    let aya: Int
    let word_idx: Int

    init(position: MushafPosition) {
        sura = position.sura
        aya = position.aya
        word_idx = position.wordIdx
    }
}

struct EndMessageDTO: Encodable {
    let type = "end"
}

/// Minimal type-erased Encodable, since `moshaf` mixes String and Int values.
struct AnyEncodable: Encodable {
    private let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
}

// MARK: - Incoming (server -> client), API.md §5.2 / §5.4 / §5.9

struct SessionAckDTO: Decodable {
    let type: String
    let session_id: String
    let engine: String
    let sample_rate: Int
}

struct DoneDTO: Decodable {
    let type: String
}

struct PositionDTO: Decodable {
    let sura: Int
    let aya: Int
    let word_idx: Int
}

struct TajweedRuleMatchDTO: Decodable {
    let name_ar: String
    let name_en: String
    let golden_len: Int?
    let correctness_type: String
    let tag: String?
}

struct RecognitionErrorDTO: Decodable {
    let error_type: String
    let speech_error_type: String
    let uthmani_pos: [Int]
    let ph_pos: [Int]
    let pred_ph_pos: [Int]?
    let expected_ph: String
    let predicted_ph: String
    let expected_len: Int?
    let predicted_len: Int?
    let tajweed_rules: [TajweedRuleMatchDTO]
    let confidence: Double?
}

struct WordFeedbackDTO: Decodable {
    let sura: Int
    let aya: Int
    let word_idx: Int
    let uthmani: String
    let status: String
    let errors: [RecognitionErrorDTO]
    let trimmed: Bool
}

struct RecognitionCandidateDTO: Decodable {
    let sura: Int
    let aya: Int
    let word_idx: Int
    let uthmani_text: String
    let end: PositionDTO?
}

struct FeedbackPayloadDTO: Decodable {
    let status: String
    let span: PositionDTO?
    let end: PositionDTO?
    let uthmani_text: String?
    let predicted_phonemes: String
    let reference_phonemes: String
    let words: [WordFeedbackDTO]
    let candidates: [RecognitionCandidateDTO]
    let non_verse: [String]
}

struct FeedbackEventDTO: Decodable {
    let type: String
    let chunk_seq: Int
    let audio_span_sec: [Double]
    let forced_cut: Bool
    let phonemes: String
    let feedback: FeedbackPayloadDTO
    let cursor: PositionDTO?
}

// MARK: - DTO -> domain mapping

extension PositionDTO {
    func toDomain() -> MushafPosition { MushafPosition(sura: sura, aya: aya, wordIdx: word_idx) }
}

extension TajweedRuleMatchDTO {
    func toDomain() -> TajweedRuleMatch {
        TajweedRuleMatch(
            nameAr: name_ar,
            nameEn: name_en,
            goldenLen: golden_len,
            correctnessType: RuleCorrectnessType(rawValue: correctness_type) ?? .match,
            tag: tag
        )
    }
}

extension RecognitionErrorDTO {
    /// A malformed range from the server is treated as an unrenderable
    /// finding rather than crashing the client; the caller drops it.
    func toDomain() -> RecognitionError? {
        guard uthmani_pos.count == 2, ph_pos.count == 2, uthmani_pos[0] <= uthmani_pos[1], ph_pos[0] <= ph_pos[1] else {
            return nil
        }
        var predRange: ClosedRange<Int>?
        if let pp = pred_ph_pos, pp.count == 2, pp[0] <= pp[1] {
            predRange = pp[0]...pp[1]
        }
        return RecognitionError(
            errorType: ErrorChannel(rawValue: error_type) ?? .normal,
            speechErrorType: SpeechErrorType(rawValue: speech_error_type) ?? .replace,
            uthmaniRange: uthmani_pos[0]...uthmani_pos[1],
            phRange: ph_pos[0]...ph_pos[1],
            predPhRange: predRange,
            expectedPh: expected_ph,
            predictedPh: predicted_ph,
            expectedLen: expected_len,
            predictedLen: predicted_len,
            tajweedRules: tajweed_rules.map { $0.toDomain() },
            confidence: confidence
        )
    }
}

extension WordFeedbackDTO {
    func toDomain() -> WordFeedback {
        WordFeedback(
            sura: sura,
            aya: aya,
            wordIdx: word_idx,
            uthmani: uthmani,
            status: WordStatus(rawValue: status) ?? .almost,
            errors: errors.compactMap { $0.toDomain() },
            trimmed: trimmed
        )
    }
}

extension RecognitionCandidateDTO {
    func toDomain() -> RecognitionCandidate {
        RecognitionCandidate(sura: sura, aya: aya, wordIdx: word_idx, uthmaniText: uthmani_text, end: end?.toDomain())
    }
}

extension FeedbackPayloadDTO {
    func toDomain() -> FeedbackPayload {
        FeedbackPayload(
            status: RecognitionStatus(rawValue: status) ?? .noMatch,
            span: span?.toDomain(),
            end: end?.toDomain(),
            uthmaniText: uthmani_text,
            predictedPhonemes: predicted_phonemes,
            referencePhonemes: reference_phonemes,
            words: words.map { $0.toDomain() },
            candidates: candidates.map { $0.toDomain() },
            nonVerse: non_verse.compactMap { NonVerseUtterance(rawValue: $0) }
        )
    }
}

extension FeedbackEventDTO {
    func toDomain() -> FeedbackEvent {
        let span = audio_span_sec.count == 2 ? audio_span_sec[0]...audio_span_sec[1] : 0...0
        return FeedbackEvent(
            chunkSeq: chunk_seq,
            audioSpanSec: span,
            forcedCut: forced_cut,
            phonemes: phonemes,
            feedback: feedback.toDomain(),
            cursor: cursor?.toDomain()
        )
    }
}

extension SessionAckDTO {
    func toDomain() -> SessionAck {
        SessionAck(sessionId: session_id, engine: ASREngine(rawValue: engine) ?? .mock, sampleRate: sample_rate)
    }
}
