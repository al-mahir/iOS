//
//  RecitationMistake.swift
//  Mualem
//

import Foundation

public struct RecitationMistake: Equatable {
    public enum MistakeType: String, Equatable {
        case tashkil
        case tajwid
        case memorization
    }
    
    public let id: UUID
    public let type: MistakeType
    public let wordIndex: Int
    public let description: String
    
    public init(id: UUID = UUID(), type: MistakeType, wordIndex: Int, description: String) {
        self.id = id
        self.type = type
        self.wordIndex = wordIndex
        self.description = description
    }
}
