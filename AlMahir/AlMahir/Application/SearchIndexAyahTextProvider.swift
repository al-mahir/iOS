//
//  SearchIndexAyahTextProvider.swift
//  AlMahir
//
//  Provides readable, normalized Arabic word text for a given Surah/Ayah
//  by querying the search-index.db bundled in the app.
//  Used by the Mu'allim module for live speech-to-text word matching.
//

import Foundation
import SQLite3
import Mualem

final class SearchIndexAyahTextProvider: AyahTextProviding {
    
    private var db: OpaquePointer?
    
    init() {
        guard let dbPath = Bundle.main.path(forResource: "search-index", ofType: "db") else {
            print("SearchIndexAyahTextProvider: search-index.db not found in bundle.")
            return
        }
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK {
            print("SearchIndexAyahTextProvider: Unable to open search-index.db.")
            db = nil
        }
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    func fetchNormalizedWords(surah: Int, ayah: Int) -> [String] {
        guard let db else { return [] }
        
        // The words_search table stores individual words with columns:
        // id, surah, ayah, text_normalized (diacritics stripped), text_display
        let query = """
            SELECT text_normalized
            FROM words_search
            WHERE surah = ? AND ayah = ?
            ORDER BY id ASC
        """
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            print("SearchIndexAyahTextProvider: Failed to prepare query.")
            return []
        }
        defer { sqlite3_finalize(stmt) }
        
        sqlite3_bind_int(stmt, 1, Int32(surah))
        sqlite3_bind_int(stmt, 2, Int32(ayah))
        
        var words: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let cStr = sqlite3_column_text(stmt, 0) {
                let word = String(cString: cStr).trimmingCharacters(in: .whitespaces)
                if !word.isEmpty {
                    words.append(word)
                }
            }
        }
        
        return words
    }
}
