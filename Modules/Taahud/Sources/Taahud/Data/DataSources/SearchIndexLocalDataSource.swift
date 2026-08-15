//
//  SearchIndexLocalDataSource.swift
//  Taahud
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
        case .databaseNotFound(let path):
            return String(
                localized: "search-index.db not found at \(path).",
                comment: "Error message when search index database file is missing"
            )
        case .openFailed(let message):
            return String(
                localized: "Failed to open search-index.db: \(message)",
                comment: "Error message when opening search index database fails"
            )
        case .queryFailed(let message):
            return String(
                localized: "search-index.db query failed: \(message)",
                comment: "Error message when executing query on search index database fails"
            )
        case .notFound:
            return String(
                localized: "No matching row found in search-index.db.",
                comment: "Error message when a search query returns no matching row"
            )
        }
    }
}

public final class SearchIndexLocalDataSource {
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.reading.taahud.searchindex")

    public init(databaseURL: URL) throws {
        var handle: OpaquePointer?
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
