// FeedbackMapper.swift
// Mualem

import Foundation

enum FeedbackMapper {
    static func mapSessionAck(_ dto: SessionAckDTO) -> MuallemSessionEvent {
        return .sessionAck(sessionId: dto.sessionId, engine: dto.engine, sampleRate: dto.sampleRate)
    }
    
    static func mapFeedback(_ dto: FeedbackEventDTO) -> MuallemSessionEvent {
        let cursor = dto.cursor.map { mapPosition($0) }
        let words = dto.feedback.words.map { mapWord($0) }
        
        let status: FeedbackStatus
        switch dto.feedback.status {
        case "ok": status = .ok
        case "ambiguous": status = .ambiguous
        case "no_match": status = .noMatch
        default: status = .ok
        }
        
        let feedback = RecitationFeedback(
            chunkSeq: dto.chunkSeq,
            status: status,
            words: words,
            cursor: cursor,
            uthmaniText: dto.feedback.uthmaniText,
            nonVerse: dto.feedback.nonVerse ?? [],
            forcedCut: dto.forcedCut
        )
        
        return .feedback(feedback)
    }
    
    static func mapWord(_ dto: WordFeedbackDTO) -> WordFeedback {
        let wordStatus: WordFeedbackStatus
        switch dto.status {
        case "correct": wordStatus = .correct
        case "error": wordStatus = .error
        case "almost": wordStatus = .almost
        default: wordStatus = .correct
        }
        
        let errors = dto.errors.map { mapError($0) }
        
        return WordFeedback(
            sura: dto.sura,
            aya: dto.aya,
            wordIdx: dto.wordIdx,
            uthmani: dto.uthmani,
            status: wordStatus,
            isTrimmed: dto.trimmed,
            errors: errors
        )
    }
    
    static func mapError(_ dto: WordErrorDTO) -> WordError {
        let confidence: ConfidenceLevel
        if let val = dto.confidence {
            confidence = .known(val)
        } else {
            confidence = .unknown
        }
        
        let errorType: RecitationErrorType
        switch dto.errorType {
        case "tajweed": errorType = .tajweed
        case "normal": errorType = .normal
        case "tashkeel": errorType = .tashkeel
        case "sifa": errorType = .sifa
        default: errorType = .normal
        }
        
        let speechErrorType: SpeechErrorType
        switch dto.speechErrorType {
        case "insert": speechErrorType = .insert
        case "delete": speechErrorType = .delete
        case "replace": speechErrorType = .replace
        default: speechErrorType = .replace
        }
        
        let rules = dto.tajweedRules?.map { mapTajweedRule($0) } ?? []
        
        return WordError(
            errorType: errorType,
            speechErrorType: speechErrorType,
            uthmaniPos: dto.uthmaniPos ?? [],
            expectedPh: dto.expectedPh ?? "",
            predictedPh: dto.predictedPh ?? "",
            expectedLen: dto.expectedLen,
            predictedLen: dto.predictedLen,
            tajweedRules: rules,
            confidence: confidence
        )
    }
    
    static func mapPosition(_ dto: PositionDTO) -> QuranPosition {
        return QuranPosition(sura: dto.sura, aya: dto.aya, wordIdx: dto.wordIdx)
    }
    
    static func mapTajweedRule(_ dto: TajweedRuleMatchDTO) -> TajweedRuleFinding {
        return TajweedRuleFinding(
            nameAr: dto.nameAr,
            nameEn: dto.nameEn,
            goldenLen: dto.goldenLen,
            correctnessType: dto.correctnessType ?? "match",
            tag: dto.tag
        )
    }
}
