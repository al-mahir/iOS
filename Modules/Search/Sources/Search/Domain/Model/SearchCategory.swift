//
//  SearchCategory.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation

enum SearchCategory: String, CaseIterable, Identifiable, Codable {

    case word     = "Word"
    case semantic = "Semantic"
    case tafsir   = "Tafsir"
    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .word:     return "text.word.spacing"
        case .semantic: return "sparkle.magnifyingglass"
        case .tafsir:   return "book.pages"
        }
    }
}

