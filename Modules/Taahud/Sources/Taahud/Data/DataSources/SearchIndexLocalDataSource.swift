//
//  SearchIndexLocalDataSource.swift
//  Reading
//
//  Data layer. Read-only queries against the bundled `search-index.db`,
//  which pairs (sura, aya, word_idx) with Uthmani display text and a global
//  word id — the id space `AyahWord.id` and `WordFeedback.wordIdx` are keyed
//  against for matching AI feedback to the on-screen Mushaf word.
//
//  Uses the SQLite3 C API directly rather than pulling in GRDB or
//  SQLite.swift as a dependency — the query surface here is small and fixed,
//  and iOS ships sqlite3 for free. Swap in GRDB/SQLite.swift by re-implementing
//  this one type if the team already depends on one of them elsewhere.
//

import Foundation
import SQLite3

struct SearchIndexWordRow {
    let globalWordId: Int
    let sura: Int
    let aya: Int
    let wordIdx: Int
    let uthmaniText: String
}

enum SearchIndexError: LocalizedError {
    case databaseNotFound(path: String)
    case openFailed(message: String)
    case queryFailed(message: String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .databaseNotFound(let path): return "search-index.db not found at \(path)."
        case .openFailed(let message): return "Failed to open search-index.db: \(message)"
        case .queryFailed(let message): return "search-index.db query failed: \(message)"
        case .notFound: return "No matching row found in search-index.db."
        }
    }
}

public final class SearchIndexLocalDataSource {
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.reading.taahud.searchindex")

    /// - Parameter databaseURL: file URL to the bundled, read-only `search-index.db`.
    public init(databaseURL: URL) throws {
        var handle: OpaquePointer?
        // SQLITE_OPEN_READONLY: this database ships with the app bundle and is
        // never written to at runtime.
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(databaseURL.path, &handle, flags, nil) == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(handle))
            sqlite3_close(handle)
            throw SearchIndexError.openFailed(message: message)
        }
        self.db = handle
    }

    deinit {
        sqlite3_close(db)
    }

    /// Fetches the word row for a given (sura, aya, wordIdx) triple.
    func fetchWord(sura: Int, aya: Int, wordIdx: Int) throws -> SearchIndexWordRow {
        try queue.sync {
            let sql = """
                SELECT id, sura, aya, word_idx, uthmani_text
                FROM ayah_words
                WHERE sura = ? AND aya = ? AND word_idx = ?
                LIMIT 1;
                """
            var statement: OpaquePointer?
            defer { sqlite3_finalize(statement) }

            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw SearchIndexError.queryFailed(message: lastErrorMessage())
            }
            sqlite3_bind_int(statement, 1, Int32(sura))
            sqlite3_bind_int(statement, 2, Int32(aya))
            sqlite3_bind_int(statement, 3, Int32(wordIdx))

            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw SearchIndexError.notFound
            }
            return row(from: statement)
        }
    }

    /// Fetches a word by its global id (used when the Mushaf side already
    /// knows the id and just needs the matching Uthmani text/position).
    func fetchWord(globalWordId: Int) throws -> SearchIndexWordRow {
        try queue.sync {
            let sql = "SELECT id, sura, aya, word_idx, uthmani_text FROM ayah_words WHERE id = ? LIMIT 1;"
            var statement: OpaquePointer?
            defer { sqlite3_finalize(statement) }

            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw SearchIndexError.queryFailed(message: lastErrorMessage())
            }
            sqlite3_bind_int(statement, 1, Int32(globalWordId))

            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw SearchIndexError.notFound
            }
            return row(from: statement)
        }
    }

    // MARK: - Helpers

    private func row(from statement: OpaquePointer?) -> SearchIndexWordRow {
        SearchIndexWordRow(
            globalWordId: Int(sqlite3_column_int(statement, 0)),
            sura: Int(sqlite3_column_int(statement, 1)),
            aya: Int(sqlite3_column_int(statement, 2)),
            wordIdx: Int(sqlite3_column_int(statement, 3)),
            uthmaniText: sqlite3_column_text(statement, 4).map { String(cString: $0) } ?? ""
        )
    }

    private func lastErrorMessage() -> String {
        String(cString: sqlite3_errmsg(db))
    }
}
