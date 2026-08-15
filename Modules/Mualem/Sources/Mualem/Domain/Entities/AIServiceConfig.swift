//
//  AIServiceConfig.swift
//  Mualem
//
//  Domain entities for AI service configuration.
//  Pure Swift — no framework imports beyond Foundation.
//

import Foundation

// MARK: - AI Health Info

public struct AIHealthInfo: Equatable {
    public let status: String
    public let defaultEngine: String
    public let availableEngines: [String]
    
    public init(status: String, defaultEngine: String, availableEngines: [String]) {
        self.status = status
        self.defaultEngine = defaultEngine
        self.availableEngines = availableEngines
    }
    
    public var isHealthy: Bool {
        status == "healthy" || status == "ok"
    }
}

// MARK: - Tajweed Rule

public struct TajweedRuleConfig: Equatable, Identifiable, Hashable {
    public let id: String  // key
    public let key: String
    public let nameAr: String
    public let nameEn: String
    public let kind: TajweedRuleKind
    
    public init(key: String, nameAr: String, nameEn: String, kind: TajweedRuleKind) {
        self.id = key
        self.key = key
        self.nameAr = nameAr
        self.nameEn = nameEn
        self.kind = kind
    }
}

public enum TajweedRuleKind: String, Equatable {
    case tajweed
    case sifa
}

// MARK: - Moshaf Schema

public struct MoshafSchemaField: Equatable, Identifiable {
    public let id: String  // key
    public let key: String
    public let nameAr: String
    public let description: String
    public let defaultValue: MoshafOptionValue
    public let options: [MoshafOption]
    
    public init(key: String, nameAr: String, description: String, defaultValue: MoshafOptionValue, options: [MoshafOption]) {
        self.id = key
        self.key = key
        self.nameAr = nameAr
        self.description = description
        self.defaultValue = defaultValue
        self.options = options
    }
}

public struct MoshafOption: Equatable, Identifiable {
    public let id: String
    public let value: MoshafOptionValue
    public let label: String
    
    public init(value: MoshafOptionValue, label: String) {
        switch value {
        case .string(let s): self.id = s
        case .integer(let i): self.id = "\(i)"
        }
        self.value = value
        self.label = label
    }
}

public enum MoshafOptionValue: Equatable {
    case string(String)
    case integer(Int)
    
    public var stringValue: String {
        switch self {
        case .string(let s): return s
        case .integer(let i): return "\(i)"
        }
    }
}

// MARK: - Session Strictness

public enum RecitationStrictness: String, CaseIterable, Equatable {
    case lenient
    case normal
    case strict
    
    public var displayName: String {
        switch self {
        case .lenient: return "Lenient"
        case .normal:  return "Normal"
        case .strict:  return "Strict"
        }
    }
    
    public var displayNameAr: String {
        switch self {
        case .lenient: return "مرن"
        case .normal:  return "معتدل"
        case .strict:  return "صارم"
        }
    }
}

// MARK: - Muallem WS Session Config

public struct MuallemWSSessionConfig: Equatable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let strictness: RecitationStrictness
    public let engine: String?
    public let rules: [String]?
    public let moshaf: [String: MoshafOptionValue]?
    
    public init(
        sura: Int,
        aya: Int,
        wordIdx: Int = 0,
        strictness: RecitationStrictness = .normal,
        engine: String? = nil,
        rules: [String]? = nil,
        moshaf: [String: MoshafOptionValue]? = nil
    ) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
        self.strictness = strictness
        self.engine = engine
        self.rules = rules
        self.moshaf = moshaf
    }
}

// MARK: - Session Events

public enum MuallemSessionEvent: Equatable {
    case sessionAck(sessionId: String, engine: String, sampleRate: Int)
    case feedback(RecitationFeedback)
    case done
    case error(MuallemSessionError)
}

public enum MuallemSessionError: Error, Equatable {
    case connectionFailed(String)
    case protocolError(String)       // close code 1002 — first message wasn't JSON
    case abnormalClose(String)       // close code 1006 — network drop
    case decodingFailed(String)
    case serverUnreachable
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .connectionFailed(let msg):  return "Connection failed: \(msg)"
        case .protocolError(let msg):     return "Protocol error: \(msg)"
        case .abnormalClose(let msg):     return "Connection lost: \(msg)"
        case .decodingFailed(let msg):    return "Decoding failed: \(msg)"
        case .serverUnreachable:          return "AI server is unreachable"
        case .unknown(let msg):           return "Unknown error: \(msg)"
        }
    }
}
