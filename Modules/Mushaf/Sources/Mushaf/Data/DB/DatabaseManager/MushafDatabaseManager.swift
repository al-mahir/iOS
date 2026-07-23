//
//  MushafDatabaseManager.swift
//  Mushaf
//

import Foundation

final class MushafDatabaseManager {
    enum SetupError: Error {
        case fileNotFound(String)
    }

    let wordsDB: SQLiteDatabase
    let layoutDB: SQLiteDatabase
    let searchDB: SQLiteDatabase

    init(wordsDBName: String = "qpc-v4",
         layoutDBName: String = "qpc-v4-tajweed-15-lines") throws {
        guard let wordsPath = Bundle.main.path(forResource: wordsDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(wordsDBName).db")
        }
        guard let layoutPath = Bundle.main.path(forResource: layoutDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(layoutDBName).db")
        }
        guard let searchPath = Bundle.main.path(forResource: "search-index", ofType: "db") else {
            throw SetupError.fileNotFound("search-index.db")
        }

        self.wordsDB = try SQLiteDatabase(path: wordsPath)
        self.layoutDB = try SQLiteDatabase(path: layoutPath)
        self.searchDB = try SQLiteDatabase(path: searchPath)
    }
}
