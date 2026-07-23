//
//  SearchIndexDAO.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 23/07/2026.
//

import Foundation

final class SearchIndexDAO: QuranSearchRepository {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    /// Fetches normalized and display text variant for a word ID from search-index.db
    func fetchSearchWord(id: Int) -> (normalized: String, display: String)? {
        guard let rows = try? db.query(
            "SELECT text_normalized, text_display FROM words_search WHERE id = \(id)"
        ), let first = rows.first else {
            return nil
        }

        let normalized = first["text_normalized"] as? String ?? ""
        let display = first["text_display"] as? String ?? ""

        guard !normalized.isEmpty || !display.isEmpty else { return nil }
        return (normalized, display)
    }
}
