//
//  MushafDatabaseManager.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//



import Foundation
 
final class MushafDatabaseManager {
    let wordsDB: SQLiteDatabase
    let layoutDB: SQLiteDatabase
    let searchDB: SQLiteDatabase?
 
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
         layoutDBName: String = "qpc-v4-tajweed-15-lines",
         searchDBName: String = "search-index") throws {
        guard let wordsPath = Bundle.main.path(forResource: wordsDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(wordsDBName).db")
        }
        guard let layoutPath = Bundle.main.path(forResource: layoutDBName, ofType: "db") else {
            throw SetupError.fileNotFound("\(layoutDBName).db")
        }
 
        self.wordsDB = try SQLiteDatabase(path: wordsPath)
        self.layoutDB = try SQLiteDatabase(path: layoutPath)
 
        if let searchPath = Bundle.main.path(forResource: searchDBName, ofType: "db") {
            self.searchDB = try? SQLiteDatabase(path: searchPath)
            if self.searchDB == nil {
                print("⚠️ Found \(searchDBName).db but failed to open it. Search will be unavailable.")
            }
        } else {
            self.searchDB = nil
            print("⚠️ \(searchDBName).db not found in bundle. Search will be unavailable until it's added.")
        }
    }
}
