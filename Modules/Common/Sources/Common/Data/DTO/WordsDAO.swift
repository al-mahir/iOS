//
//  WordsDAO.swift
//  Common
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Foundation

public final class WordsDAO {
    private let db: SQLiteDatabase

    public init(db: SQLiteDatabase) {
        self.db = db
    }

    public func fetchWords(fromId: Int, toId: Int) throws -> [WordRow] {
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
    
    public func wordIdRange(surah: Int) throws -> (first: Int, last: Int)? {
        let rows = try db.query(
            "SELECT MIN(id) as min_id, MAX(id) as max_id FROM words WHERE surah = ?",
            bind: [surah]
        )
        guard let row = rows.first,
              let minId = row["min_id"] as? Int,
              let maxId = row["max_id"] as? Int else {
            return nil
        }
        return (minId, maxId)
    }

    /// First/last word id for an inclusive Ayah range within one Surah.
    public func wordIdRange(surah: Int, fromAyah: Int, toAyah: Int) throws -> (first: Int, last: Int)? {
        let rows = try db.query(
            """
            SELECT MIN(id) as min_id, MAX(id) as max_id
            FROM words
            WHERE surah = ? AND ayah BETWEEN ? AND ?
            """,
            bind: [surah, fromAyah, toAyah]
        )
        guard let row = rows.first,
              let minId = row["min_id"] as? Int,
              let maxId = row["max_id"] as? Int else {
            return nil
        }
        return (minId, maxId)
    }

    public func ayahBoundaries(fromWordId: Int, toWordId: Int) throws -> [(surah: Int, ayah: Int, firstWordId: Int, lastWordId: Int)] {
        let rows = try db.query(
            """
            SELECT surah, ayah, MIN(id) as first_id, MAX(id) as last_id
            FROM words
            WHERE id BETWEEN ? AND ?
            GROUP BY surah, ayah
            ORDER BY MIN(id) ASC
            """,
            bind: [fromWordId, toWordId]
        )
        return rows.compactMap { row in
            guard let surah = row["surah"] as? Int,
                  let ayah = row["ayah"] as? Int,
                  let firstId = row["first_id"] as? Int,
                  let lastId = row["last_id"] as? Int else { return nil }
            return (surah, ayah, firstId, lastId)
        }
    }
}
