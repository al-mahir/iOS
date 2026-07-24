//
//  QuranSearchRepositoryImpl.swift
//  Reading
//

import Mushaf

final class QuranSearchRepositoryImpl: QuranSearchRepository {
    private let db: SQLiteDatabase

    init(db: SQLiteDatabase) {
        self.db = db
    }

    func fetchSearchWord(id: Int) -> (normalized: String, display: String)? {
        do {
            
            let rows = try db.query(
                "SELECT text_normalized, text_display FROM words_search WHERE id = ?",
                bind: [id]
            )
            
            guard let first = rows.first else {
                print("⚠️ [DB Lookup] No row returned for word ID \(id)")
                return nil
            }

            let normalized = first["text_normalized"] as? String ?? ""
            let display = first["text_display"] as? String ?? ""

            if normalized.isEmpty && display.isEmpty {
                print("⚠️ [DB Lookup] Row found for ID \(id) but both fields are empty")
                return nil
            }

            print("✅ [DB Lookup] SUCCESS for ID \(id) -> normalized: '\(normalized)', display: '\(display)'")
            return (normalized, display)
        } catch {
            print("❌ [DB Lookup] SQL EXCEPTION for ID \(id): \(error)")
            return nil
        }
    }
}
