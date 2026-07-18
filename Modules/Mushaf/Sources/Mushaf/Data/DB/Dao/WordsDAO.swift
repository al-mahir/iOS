//
//  WordsDAO.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Foundation



final class WordsDAO {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    func fetchWords(fromId: Int, toId: Int) throws -> [WordRow] {
        let rows = try db.query(
            """
            SELECT id, surah, ayah, word, text
            FROM words
            WHERE id BETWEEN ? AND ?
            ORDER BY id ASC
            """,
            bind: [fromId, toId]
        )

        return rows.map {
            WordRow(
                id: $0["id"] as? Int ?? 0,
                surah: $0["surah"] as? Int ?? 0,
                ayah: $0["ayah"] as? Int ?? 0,
                word: $0["word"] as? Int ?? 0,
                text: $0["text"] as? String ?? ""
            )
        }
    }
}
