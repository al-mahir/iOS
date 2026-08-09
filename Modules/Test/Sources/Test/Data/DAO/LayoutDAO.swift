//
//  LayoutDAO.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 08/08/2026.
//


import Foundation
import Common
public final class LayoutDAO {
    private let db: SQLiteDatabase

    public init(db: SQLiteDatabase) {
        self.db = db
    }

    /// Maps each word id in [fromId, toId] to its printed page number,
    /// using the line-range table in qpc-v4-tajweed-15-lines.db.
    public func pageNumbers(fromId: Int, toId: Int) throws -> [Int: Int] {
        let rows = try db.query(
            """
            SELECT page_number, first_word_id, last_word_id
            FROM pages
            WHERE line_type = 'ayah'
              AND first_word_id <= ?
              AND last_word_id >= ?
            ORDER BY first_word_id ASC
            """,
            bind: [toId, fromId]
        )

        let ranges: [(page: Int, first: Int, last: Int)] = rows.compactMap {
            guard let page = $0["page_number"] as? Int,
                  let first = $0["first_word_id"] as? Int,
                  let last = $0["last_word_id"] as? Int else { return nil }
            return (page, first, last)
        }

        var result: [Int: Int] = [:]
        for id in fromId...toId {
            if let match = ranges.first(where: { id >= $0.first && id <= $0.last }) {
                result[id] = match.page
            }
        }
        return result
    }
}
