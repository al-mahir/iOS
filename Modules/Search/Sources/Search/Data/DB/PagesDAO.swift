//
//  PagesDAO.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//



import Foundation

final class PagesDAO {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    func pageNumber(forWordId wordId: Int) throws -> Int? {
        let rows = try db.query(
            """
            SELECT page_number
            FROM pages
            WHERE ? BETWEEN first_word_id AND last_word_id
            LIMIT 1
            """,
            bind: [wordId]
        )
        return rows.first?["page_number"] as? Int
    }
}
