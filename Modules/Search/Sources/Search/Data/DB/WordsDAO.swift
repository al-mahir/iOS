//
//  WordsDAO.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//


import Foundation

final class WordsDAO {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    func wordIdRange(surah: Int, ayah: Int) throws -> (first: Int, last: Int)? {
        let rows = try db.query(
            "SELECT MIN(id) AS first_id, MAX(id) AS last_id FROM words WHERE surah = ? AND ayah = ?",
            bind: [surah, ayah]
        )
        guard let row = rows.first,
              let first = row["first_id"] as? Int,
              let last = row["last_id"] as? Int else { return nil }
        return (first, last)
    }
}
