//
//  SearchCategory.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI

enum SearchCategory: String, CaseIterable, Identifiable, Codable {
    case word     = "Word"
    case tafsir   = "Tafsir"
    
    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .word:     return "text.word.spacing"
        case .tafsir:   return "book.pages"
        }
    }

    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
