//
//  BookmarkTab.swift
//  Bookmarks (Presentation)
//

import Foundation

enum BookmarkTab: String, CaseIterable, Identifiable {
    case surah, ayah, page, sheikh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .surah:  return "Surah"
        case .ayah:   return "Ayah"
        case .page:   return "Page"
        case .sheikh: return "Sheikh"
        }
    }
}
