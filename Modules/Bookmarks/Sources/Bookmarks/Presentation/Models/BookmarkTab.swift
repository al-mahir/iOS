//
//  BookmarkTab.swift
//  Bookmarks (Presentation)
//

import Foundation
import SwiftUI
import Common

enum BookmarkTab: String, CaseIterable, Identifiable {
    case surah
    case ayah
    case page
    case sheikh

    var id: String {
        rawValue
    }

    @MainActor
    var title: String {
        switch self {
        case .surah:
            return LanguageManager.localizedString(
                "bookmark.tab.surah",
                bundle: .module
            )

        case .ayah:
            return LanguageManager.localizedString(
                "bookmark.tab.ayah",
                bundle: .module
            )

        case .page:
            return LanguageManager.localizedString(
                "bookmark.tab.page",
                bundle: .module
            )

        case .sheikh:
            return LanguageManager.localizedString(
                "bookmark.tab.sheikh",
                bundle: .module
            )
        }
    }
}
