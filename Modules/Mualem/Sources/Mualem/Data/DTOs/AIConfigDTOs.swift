// AIConfigDTOs.swift
// Mualem

import Foundation

struct HealthResponseDTO: Decodable {
    let status: String
    let engine: String
    let availableEngines: [String]
    
    enum CodingKeys: String, CodingKey {
        case status
        case engine
        case availableEngines = "available_engines"
    }
}

struct TajweedRulesResponseDTO: Decodable {
    let rules: [TajweedRuleDTO]
}

struct TajweedRuleDTO: Decodable {
    let key: String
    let nameAr: String
    let nameEn: String
    let kind: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case kind
    }
}

struct MoshafSchemaResponseDTO: Decodable {
    let fields: [MoshafSchemaFieldDTO]
}

struct MoshafSchemaFieldDTO: Decodable {
    let key: String
    let nameAr: String
    let description: String
    let defaultValue: AnyDecodableValue
    let options: [MoshafOptionDTO]
    
    enum CodingKeys: String, CodingKey {
        case key
        case nameAr = "name_ar"
        case description
        case defaultValue = "default"
        case options
    }
}

enum AnyDecodableValue: Decodable {
    case string(String)
    case integer(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let int = try? container.decode(Int.self) {
            self = .integer(int)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected String or Int")
        }
    }
}

struct MoshafOptionDTO: Decodable {
    let value: AnyDecodableValue
    let label: String
}
