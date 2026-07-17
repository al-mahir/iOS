//
//  PagesDAO.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation



final class PagesDAO {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    func fetchLines(forPage pageNumber: Int) throws -> [PageLineRow] {
        let rows = try db.query(
            """
            SELECT line_number, line_type, is_centered, first_word_id, last_word_id, surah_number
            FROM pages
            WHERE page_number = ?
            ORDER BY line_number ASC
            """,
            bind: [pageNumber]
        )

        return rows.map {
            PageLineRow(
                lineNumber: $0["line_number"] as? Int ?? 0,
                lineType: $0["line_type"] as? String ?? "ayah",
                isCentered: ($0["is_centered"] as? Int ?? 0) == 1,
                firstWordId: $0["first_word_id"] as? Int,
                lastWordId: $0["last_word_id"] as? Int,
                surahNumber: $0["surah_number"] as? Int
            )
        }
    }
}