//
//  QPCV4LocalDataSource.swift
//  Taahud
//
//  Data layer.

import Foundation
import SQLite3

enum QPCV4Error: LocalizedError {
    case openFailed(message: String)
    case queryFailed(message: String)
    case pageNotFound(Int)
    case wordNotFound

    var errorDescription: String? {
        switch self {
        case .openFailed(let message):
            return String(
                localized: "Failed to open qpc_v4.db: \(message)",
                comment: "Error message when opening the SQLite database fails"
            )
        case .queryFailed(let message):
            return String(
                localized: "qpc_v4.db query failed: \(message)",
                comment: "Error message when executing a SQL query fails"
            )
        case .pageNotFound(let page):
            return String(
                localized: "Mushaf page \(page) not found in qpc_v4.db.",
                comment: "Error message when a requested page is not found in database"
            )
        case .wordNotFound:
            return String(
                localized: "No matching word found in qpc_v4.db for that position.",
                comment: "Error message when a word lookup returns no results"
            )
        }
    }
}

public final class QPCV4LocalDataSource {
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.reading.taahud.qpcv4")

    public init(databaseURL: URL) throws {
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(databaseURL.path, &handle, flags, nil) == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(handle))
            sqlite3_close(handle)
            throw QPCV4Error.openFailed(message: message)
        }
        self.db = handle
    }

    deinit {
        sqlite3_close(db)
    }
    
    func fetchPage(pageNumber: Int) throws -> MushafPageData {
        try queue.sync {
            let sql = """
                SELECT id, sura, aya, word_position, line_number, is_centered,
                       glyph_code_point, uthmani_text, is_verse_marker, juz
                FROM words
                WHERE page_number = ?
                ORDER BY line_number ASC, word_position ASC;
                """
            var statement: OpaquePointer?
            defer { sqlite3_finalize(statement) }

            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw QPCV4Error.queryFailed(message: lastErrorMessage())
            }
            sqlite3_bind_int(statement, 1, Int32(pageNumber))

            var wordsByLine: [Int: [AyahWord]] = [:]
            var lineIsCentered: [Int: Bool] = [:]
            var juz = 0
            var rowCount = 0

            while sqlite3_step(statement) == SQLITE_ROW {
                rowCount += 1
                let lineNumber = Int(sqlite3_column_int(statement, 4))
                let word = AyahWord(
                    id: Int(sqlite3_column_int(statement, 0)),
                    sura: Int(sqlite3_column_int(statement, 1)),
                    aya: Int(sqlite3_column_int(statement, 2)),
                    wordPosition: Int(sqlite3_column_int(statement, 3)),
                    text: sqlite3_column_text(statement, 7).map { String(cString: $0) } ?? "",
                    glyphCodePoint: sqlite3_column_text(statement, 6).map { String(cString: $0) } ?? "",
                    lineNumber: lineNumber,
                    isVerseMarker: sqlite3_column_int(statement, 8) != 0
                )
                wordsByLine[lineNumber, default: []].append(word)
                lineIsCentered[lineNumber] = sqlite3_column_int(statement, 5) != 0
                juz = Int(sqlite3_column_int(statement, 9))
            }

            guard rowCount > 0 else {
                throw QPCV4Error.pageNotFound(pageNumber)
            }

            let lines = wordsByLine.keys.sorted().map { lineNumber in
                MushafLine(
                    id: lineNumber,
                    lineNumber: lineNumber,
                    words: wordsByLine[lineNumber] ?? [],
                    isCentered: lineIsCentered[lineNumber] ?? false
                )
            }

            return MushafPageData(pageNumber: pageNumber, juz: juz, lines: lines)
        }
    }

    /// Resolves which page a given (sura, aya, wordPosition) triple lands on.
    func pageNumber(forSura sura: Int, aya: Int, wordPosition: Int) throws -> Int {
        try queue.sync {
            let sql = """
                SELECT page_number FROM words
                WHERE sura = ? AND aya = ? AND word_position = ?
                LIMIT 1;
                """
            var statement: OpaquePointer?
            defer { sqlite3_finalize(statement) }

            guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
                throw QPCV4Error.queryFailed(message: lastErrorMessage())
            }
            sqlite3_bind_int(statement, 1, Int32(sura))
            sqlite3_bind_int(statement, 2, Int32(aya))
            sqlite3_bind_int(statement, 3, Int32(wordPosition))

            guard sqlite3_step(statement) == SQLITE_ROW else {
                throw QPCV4Error.wordNotFound
            }
            return Int(sqlite3_column_int(statement, 0))
        }
    }

    private func lastErrorMessage() -> String {
        String(cString: sqlite3_errmsg(db))
    }
}
