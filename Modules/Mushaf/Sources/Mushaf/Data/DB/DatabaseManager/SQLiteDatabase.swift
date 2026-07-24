//
//  SQLiteDatabase.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation
import SQLite3

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public final class SQLiteDatabase {
    enum DBError: Error, LocalizedError {
        case openFailed(String)
        case prepareFailed(String)

        var errorDescription: String? {
            switch self {
            case .openFailed(let msg): return "Could not open database: \(msg)"
            case .prepareFailed(let msg): return "Could not prepare statement: \(msg)"
            }
        }
    }

    private var db: OpaquePointer?

    private let queue = DispatchQueue(label: "com.mushaf.sqlitedatabase")

    public init(path: String) throws {
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(path, &handle, flags, nil) != SQLITE_OK {
            let msg = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown error"
            if let handle { sqlite3_close_v2(handle) }
            throw DBError.openFailed(msg)
        }
        self.db = handle
    }

    deinit {
        sqlite3_close_v2(db)
    }

    public func query(_ sql: String, bind: [Any] = []) throws -> [[String: Any]] {
        try queue.sync {
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }

            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DBError.prepareFailed(String(cString: sqlite3_errmsg(db)))
            }

            for (index, value) in bind.enumerated() {
                let position = Int32(index + 1)
                switch value {
                case let v as Int:
                    sqlite3_bind_int(stmt, position, Int32(v))
                case let v as String:
                    sqlite3_bind_text(stmt, position, (v as NSString).utf8String, -1, SQLITE_TRANSIENT)
                default:
                    sqlite3_bind_null(stmt, position)
                }
            }

            var rows: [[String: Any]] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                var row: [String: Any] = [:]
                let columnCount = sqlite3_column_count(stmt)
                for column in 0..<columnCount {
                    let name = String(cString: sqlite3_column_name(stmt, column))
                    switch sqlite3_column_type(stmt, column) {
                    case SQLITE_INTEGER:
                        row[name] = Int(sqlite3_column_int64(stmt, column))
                    case SQLITE_FLOAT:
                        row[name] = sqlite3_column_double(stmt, column)
                    case SQLITE_TEXT:
                        row[name] = String(cString: sqlite3_column_text(stmt, column))
                    default:
                        break
                    }
                }
                rows.append(row)
            }
            return rows
        }
    }

    func printSchema(table: String = "words") {
        if let rows = try? query("PRAGMA table_info(\(table))") {
            print("Schema for \(table):")
            for row in rows {
                print(" -", row["name"] ?? "?", "(", row["type"] ?? "?", ")")
            }
        }
    }
}
