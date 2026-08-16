//
//  BookmarkTab.swift
//  Bookmarks (Presentation)
//

import Foundation
import SwiftUI

enum BookmarkTab: String, CaseIterable, Identifiable {
    case surah, ayah, page, sheikh

    var id: String { rawValue }

    var title: String {
        switch self {
        case .surah:
            return NSLocalizedString("bookmark.tab.surah", bundle: Bundle.module, comment: "Surah tab title")
        case .ayah:
            return NSLocalizedString("bookmark.tab.ayah", bundle: Bundle.module, comment: "Ayah tab title")
        case .page:
            return NSLocalizedString("bookmark.tab.page", bundle: Bundle.module, comment: "Page tab title")
        case .sheikh:
            return NSLocalizedString("bookmark.tab.sheikh", bundle: Bundle.module, comment: "Sheikh tab title")
        }
    }
}
