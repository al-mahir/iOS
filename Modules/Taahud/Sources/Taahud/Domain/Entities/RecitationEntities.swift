//
//  RecitationEntities.swift
//  Taahud
//

import Foundation

// MARK: - Strictness / Engine / Rules

public enum RecitationStrictness: String, Codable, CaseIterable {
    case lenient
    case normal
    case strict
}

public enum RecitationEngine: String, Codable, CaseIterable {
    case real
    case zipformer
    case mock
}

public struct TajweedRule: RawRepresentable, Codable, Hashable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let aaredMadd = TajweedRule(rawValue: "aared_madd")
    public static let ghonna = TajweedRule(rawValue: "ghonna")
    public static let qalqalah = TajweedRule(rawValue: "qalqalah")
    public static let ikhfa = TajweedRule(rawValue: "ikhfa")
    public static let idghaam = TajweedRule(rawValue: "idghaam")
}

// MARK: - Session

/// A single live recitation session against the AI engine.
public struct RecitationSession: Equatable {
    public let sessionId: String
    public let engine: RecitationEngine
    public let sampleRate: Int
    public var cursor: RecitationCursor

    public init(sessionId: String, engine: RecitationEngine, sampleRate: Int, cursor: RecitationCursor) {
        self.sessionId = sessionId
        self.engine = engine
        self.sampleRate = sampleRate
        self.cursor = cursor
    }
}

public struct RecitationCursor: Equatable, Codable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int

    public init(sura: Int, aya: Int, wordIdx: Int) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
}

// MARK: - Feedback

public enum WordFeedbackStatus: String, Codable {
    case correct
    case error
    case almost
    case trimmed
    case unknown

    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = WordFeedbackStatus(rawValue: raw) ?? .unknown
    }
}

public struct UthmaniPosition: Equatable, Codable {
    public let start: Int
    public let end: Int

    public var range: Range<Int>? {
        guard start <= end, start >= 0 else { return nil }
        return start..<end
    }
}

public struct TajweedError: Equatable, Codable, Identifiable {
    public enum ErrorType: String, Codable {
        case tajweed
        case normal
        case tashkeel
        case sifa
        case unknown
    }

    public enum SpeechErrorType: String, Codable {
        case insert
        case delete
        case replace
        case unknown
    }

    public struct RuleInfo: Equatable, Codable {
        public let nameAr: String
        public let nameEn: String
        public let goldenLen: Int?
        public let correctnessType: String?
        public let tag: String?

        public init(nameAr: String, nameEn: String, goldenLen: Int?, correctnessType: String?, tag: String?) {
            self.nameAr = nameAr
            self.nameEn = nameEn
            self.goldenLen = goldenLen
            self.correctnessType = correctnessType
            self.tag = tag
        }
    }

    public var id: String {
        "\(errorType.rawValue)-\(speechErrorType?.rawValue ?? "-")-\(position?.start ?? -1)-\(position?.end ?? -1)"
    }

    public let errorType: ErrorType
    public let speechErrorType: SpeechErrorType?
    public let position: UthmaniPosition?
    public let expectedPh: String
    public let predictedPh: String
    public let expectedLen: Int?
    public let predictedLen: Int?
    public let tajweedRules: [RuleInfo]
    public let confidence: Double?

    public var rule: String {
        if let first = tajweedRules.first {
            return Locale.current.language.languageCode?.identifier == "ar" ? first.nameAr : first.nameEn
        }
        return errorType.rawValue
    }
    
    public var message: String {
        if let first = tajweedRules.first, let expected = expectedLen, let predicted = predictedLen {
            let ruleName = Locale.current.language.languageCode?.identifier == "ar" ? first.nameAr : first.nameEn
            return String(
                localized: "\(ruleName): expected \(expected), held \(predicted)",
                comment: "Tajweed error duration description displaying expected vs predicted duration"
            )
        }
        
        switch errorType {
        case .normal:
            switch speechErrorType {
            case .insert:
                return String(localized: "Extra word", comment: "Speech error: inserted word")
            case .delete:
                return String(localized: "Missing word", comment: "Speech error: omitted word")
            default:
                return String(localized: "Wrong word", comment: "Speech error: incorrect word")
            }
        case .tashkeel:
            return String(localized: "Wrong ḥaraka", comment: "Diacritic/tashkeel mistake")
        case .sifa:
            return String(localized: "Articulation mismatch", comment: "Letter articulation or sifa mistake")
        case .tajweed:
            if let first = tajweedRules.first {
                return Locale.current.language.languageCode?.identifier == "ar" ? first.nameAr : first.nameEn
            }
            return String(localized: "Tajwīd mistake", comment: "General tajweed mistake")
        case .unknown:
            return String(localized: "Recitation mistake", comment: "General recitation mistake")
        }
    }

    public init(errorType: ErrorType, speechErrorType: SpeechErrorType?, position: UthmaniPosition?,
                expectedPh: String, predictedPh: String, expectedLen: Int?, predictedLen: Int?,
                tajweedRules: [RuleInfo], confidence: Double?) {
        self.errorType = errorType
        self.speechErrorType = speechErrorType
        self.position = position
        self.expectedPh = expectedPh
        self.predictedPh = predictedPh
        self.expectedLen = expectedLen
        self.predictedLen = predictedLen
        self.tajweedRules = tajweedRules
        self.confidence = confidence
    }
}

public struct RecitationWordKey: Hashable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int

    public init(sura: Int, aya: Int, wordIdx: Int) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
}

public struct WordFeedback: Equatable, Identifiable {
    public var id: RecitationWordKey { key }
    public let wordIdx: Int
    public let sura: Int
    public let aya: Int
    public let status: WordFeedbackStatus
    public let trimmed: Bool
    public let uthmaniPosition: UthmaniPosition?
    public let errors: [TajweedError]

    public var key: RecitationWordKey { RecitationWordKey(sura: sura, aya: aya, wordIdx: wordIdx) }

    public var countsAsHardError: Bool {
        status == .error
    }

    public init(wordIdx: Int, sura: Int, aya: Int, status: WordFeedbackStatus, trimmed: Bool,
                uthmaniPosition: UthmaniPosition?, errors: [TajweedError]) {
        self.wordIdx = wordIdx
        self.sura = sura
        self.aya = aya
        self.status = status
        self.trimmed = trimmed
        self.uthmaniPosition = uthmaniPosition
        self.errors = errors
    }
}

public struct RecitationFeedbackEvent: Equatable {
    public let chunkSeq: Int
    public let words: [WordFeedback]
    public let cursor: RecitationCursor?
}

// MARK: - Mushaf

public struct AyahWord: Equatable, Identifiable {
    public let id: Int
    public let sura: Int
    public let aya: Int
    public let wordPosition: Int
    public let text: String
    public let glyphCodePoint: String
    public let lineNumber: Int
    public let isVerseMarker: Bool
}

public struct MushafLine: Equatable, Identifiable {
    public let id: Int
    public let lineNumber: Int
    public let words: [AyahWord]
    public let isCentered: Bool
}

public struct MushafPageData: Equatable, Identifiable {
    public var id: Int { pageNumber }
    public let pageNumber: Int
    public let juz: Int
    public let lines: [MushafLine]

    public var words: [AyahWord] { lines.flatMap(\.words) }
}
