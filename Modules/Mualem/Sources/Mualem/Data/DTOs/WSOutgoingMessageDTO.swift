// WSOutgoingMessageDTO.swift
// Mualem

import Foundation

enum AnyCodableValue: Encodable {
    case string(String)
    case integer(Int)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .integer(let integer):
            try container.encode(integer)
        }
    }
}

struct StartMessageDTO: Encodable {
    let type = "start"
    var sura: Int?
    var aya: Int?
    var wordIdx: Int?
    var strictness: String?
    var engine: String?
    var rules: [String]?
    var moshaf: [String: AnyCodableValue]?
    var includeUnits: Bool?
    
    enum CodingKeys: String, CodingKey {
        case type
        case sura
        case aya
        case wordIdx = "word_idx"
        case strictness
        case engine
        case rules
        case moshaf
        case includeUnits = "include_units"
    }
}

struct SeekMessageDTO: Encodable {
    let type = "seek"
    let sura: Int
    let aya: Int
    let wordIdx: Int?
    
    enum CodingKeys: String, CodingKey {
        case type
        case sura
        case aya
        case wordIdx = "word_idx"
    }
}

struct EndMessageDTO: Encodable {
    let type = "end"
}
