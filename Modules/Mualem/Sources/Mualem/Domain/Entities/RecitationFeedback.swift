//
//  RecitationFeedback.swift
//  Mualem
//
//  Domain entities for AI recitation feedback.
//  Pure Swift — no framework imports beyond Foundation.
//

import Foundation

// MARK: - Quran Position

public struct QuranPosition: Equatable, Hashable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    
    public init(sura: Int, aya: Int, wordIdx: Int) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
    
    /// Word key format used by MushafPageView: "sura:aya:wordPosition"
    /// Note: wordPosition in Mushaf is 1-based, wordIdx from AI is 0-based
    public var mushafWordKey: String {
        "\(sura):\(aya):\(wordIdx + 1)"
    }
}

// MARK: - Feedback Status

public enum FeedbackStatus: String, Equatable {
    case ok
    case ambiguous
    case noMatch = "no_match"
}

// MARK: - Word Feedback Status

public enum WordFeedbackStatus: String, Equatable {
    case correct
    case almost
    case error
}

// MARK: - Error Type

public enum RecitationErrorType: String, Equatable {
    case tajweed
    case normal
    case tashkeel
    case sifa
}

// MARK: - Speech Error Type

public enum SpeechErrorType: String, Equatable {
    case insert
    case delete
    case replace
}

// MARK: - Confidence

public enum ConfidenceLevel: Equatable {
    case known(Double)
    case unknown
}

// MARK: - Tajweed Rule Finding

public struct TajweedRuleFinding: Equatable, Identifiable {
    public let id: UUID
    public let nameAr: String
    public let nameEn: String
    public let goldenLen: Int?
    public let correctnessType: String  // "match" or "count"
    public let tag: String?
    
    public init(nameAr: String, nameEn: String, goldenLen: Int?, correctnessType: String, tag: String?) {
        self.id = UUID()
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.goldenLen = goldenLen
        self.correctnessType = correctnessType
        self.tag = tag
    }
}

// MARK: - Word Error

public struct WordError: Equatable, Identifiable {
    public let id: UUID
    public let errorType: RecitationErrorType
    public let speechErrorType: SpeechErrorType
    public let uthmaniPos: [Int]          // [start, end] character range for highlighting
    public let expectedPh: String
    public let predictedPh: String
    public let expectedLen: Int?
    public let predictedLen: Int?
    public let tajweedRules: [TajweedRuleFinding]
    public let confidence: ConfidenceLevel
    
    public init(
        errorType: RecitationErrorType,
        speechErrorType: SpeechErrorType,
        uthmaniPos: [Int],
        expectedPh: String,
        predictedPh: String,
        expectedLen: Int?,
        predictedLen: Int?,
        tajweedRules: [TajweedRuleFinding],
        confidence: ConfidenceLevel
    ) {
        self.id = UUID()
        self.errorType = errorType
        self.speechErrorType = speechErrorType
        self.uthmaniPos = uthmaniPos
        self.expectedPh = expectedPh
        self.predictedPh = predictedPh
        self.expectedLen = expectedLen
        self.predictedLen = predictedLen
        self.tajweedRules = tajweedRules
        self.confidence = confidence
    }
    
    /// Human-readable description for the mistake sheet
    public var localizedDescription: String {
        switch errorType {
        case .tajweed:
            if let rule = tajweedRules.first {
                if let golden = rule.goldenLen, let predicted = predictedLen {
                    return "\(rule.nameAr): expected \(golden), you held \(predicted)"
                }
                return "\(rule.nameAr) (\(rule.nameEn))"
            }
            return "Tajweed error"
        case .tashkeel:
            return "Tashkeel: expected \"\(expectedPh)\", heard \"\(predictedPh)\""
        case .normal:
            switch speechErrorType {
            case .delete:  return "Word was not recited"
            case .insert:  return "Extra word inserted"
            case .replace: return "Wrong word: expected \"\(expectedPh)\", heard \"\(predictedPh)\""
            }
        case .sifa:
            if let rule = tajweedRules.first {
                return "\(rule.nameAr) (\(rule.nameEn))"
            }
            return "Articulation error"
        }
    }
}

// MARK: - Word Feedback

public struct WordFeedback: Equatable, Identifiable {
    public let id: UUID
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let uthmani: String
    public let status: WordFeedbackStatus
    public let isTrimmed: Bool
    public let errors: [WordError]
    
    public init(
        sura: Int,
        aya: Int,
        wordIdx: Int,
        uthmani: String,
        status: WordFeedbackStatus,
        isTrimmed: Bool,
        errors: [WordError]
    ) {
        self.id = UUID()
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
        self.uthmani = uthmani
        self.status = status
        self.isTrimmed = isTrimmed
        self.errors = errors
    }
    
    public var position: QuranPosition {
        QuranPosition(sura: sura, aya: aya, wordIdx: wordIdx)
    }
    
    /// Effective display status respecting the three rendering rules:
    /// - trimmed → .neutral (not scored)
    /// - almost → .hint (not a mistake)
    /// - correct/error → as-is
    public var displayStatus: WordDisplayStatus {
        if isTrimmed { return .neutral }
        switch status {
        case .correct: return .correct
        case .almost:  return .hint
        case .error:   return .error
        }
    }
}

public enum WordDisplayStatus: Equatable {
    case correct
    case hint       // almost — the model is uncertain, render as gentle hint
    case error
    case neutral    // trimmed — not scored, render without any marking
}

// MARK: - Recitation Feedback (one chunk)

public struct RecitationFeedback: Equatable {
    public let chunkSeq: Int
    public let status: FeedbackStatus
    public let words: [WordFeedback]
    public let cursor: QuranPosition?
    public let uthmaniText: String?
    public let nonVerse: [String]
    public let forcedCut: Bool
    
    public init(
        chunkSeq: Int,
        status: FeedbackStatus,
        words: [WordFeedback],
        cursor: QuranPosition?,
        uthmaniText: String?,
        nonVerse: [String],
        forcedCut: Bool
    ) {
        self.chunkSeq = chunkSeq
        self.status = status
        self.words = words
        self.cursor = cursor
        self.uthmaniText = uthmaniText
        self.nonVerse = nonVerse
        self.forcedCut = forcedCut
    }
}

// MARK: - Ayah Feedback Result (aggregated for display)

public struct AyahFeedbackResult: Equatable {
    public let words: [WordFeedback]
    public let ayahText: String
    public let sura: Int
    public let aya: Int
    public let nonVerse: [String]
    
    public init(words: [WordFeedback], ayahText: String, sura: Int, aya: Int, nonVerse: [String] = []) {
        self.words = words
        self.ayahText = ayahText
        self.sura = sura
        self.aya = aya
        self.nonVerse = nonVerse
    }
    
    public var correctCount: Int { words.filter { $0.displayStatus == .correct }.count }
    public var hintCount: Int { words.filter { $0.displayStatus == .hint }.count }
    public var errorCount: Int { words.filter { $0.displayStatus == .error }.count }
    public var neutralCount: Int { words.filter { $0.displayStatus == .neutral }.count }
    
    /// Scored words only (excluding trimmed)
    public var scoredCount: Int { words.filter { !$0.isTrimmed }.count }
    
    /// Accuracy as percentage of total words in the Ayah (un-evaluated or trimmed words lower completion)
    public var accuracy: Double {
        guard !words.isEmpty else { return 0.0 }
        return Double(correctCount + hintCount) / Double(words.count)
    }
    
    public var overallStatus: WordDisplayStatus {
        if errorCount == 0 { return .correct }
        return .error
    }
    
    /// All errors from all words, flattened
    public var allErrors: [WordError] {
        words.flatMap { $0.errors }
    }
}
