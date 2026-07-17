//
//  MushafDatabaseManager.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation


final class MushafDatabaseManager {
    let wordsDB: SQLiteDatabase
    let layoutDB: SQLiteDatabase

    enum SetupError: Error, LocalizedError {
        case fileNotFound(String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let name):
                return "Could not find \(name) in the app bundle. Check it's added to your target."
            }
        }
    }

    init(wordsDBName: String = "qpc-v4",
         layoutDBName: String = "qpc-v4-tajweed-15-lines") throws {
        guard let wordsPath = Bundle.main.path(forResource: wordsDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(wordsDBName).db")
        }
        guard let layoutPath = Bundle.main.path(forResource: layoutDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(layoutDBName).db")
        }

        self.wordsDB = try SQLiteDatabase(path: wordsPath)
        self.layoutDB = try SQLiteDatabase(path: layoutPath)
    }
}
