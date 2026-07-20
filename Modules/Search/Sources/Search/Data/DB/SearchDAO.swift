//
//  SearchDAO.swift
//  Mushaf
//


final class SearchDAO {
    private let db: SQLiteDatabase
 
    init(db: SQLiteDatabase) {
        self.db = db
    }
 
    /// `normalizedQuery` must already be run through String.normalizedArabic()
    /// before calling this, so it matches the stored text_normalized column.
    func searchWords(normalizedQuery: String) throws -> [SearchWordRow] {
        let rows = try db.query(
            """
            SELECT id, surah, ayah, text_normalized, text_display
            FROM words_search
            WHERE text_normalized LIKE ?
            ORDER BY id ASC
            """,
            bind: ["%\(normalizedQuery)%"]
        )
        return rows.map(Self.mapRow)
    }
 
    /// All words of one ayah, in order — used to build a readable display
    /// string for a search result and to resolve its page number.
    func wordsForAyah(surah: Int, ayah: Int) throws -> [SearchWordRow] {
        let rows = try db.query(
            """
            SELECT id, surah, ayah, text_normalized, text_display
            FROM words_search
            WHERE surah = ? AND ayah = ?
            ORDER BY id ASC
            """,
            bind: [surah, ayah]
        )
        return rows.map(Self.mapRow)
    }
 
    private static func mapRow(_ row: [String: Any]) -> SearchWordRow {
        SearchWordRow(
            id: row["id"] as? Int ?? 0,
            surah: row["surah"] as? Int ?? 0,
            ayah: row["ayah"] as? Int ?? 0,
            textNormalized: row["text_normalized"] as? String ?? "",
            textDisplay: row["text_display"] as? String ?? ""
        )
    }
}
