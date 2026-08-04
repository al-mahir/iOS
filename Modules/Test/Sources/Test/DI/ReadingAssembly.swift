//
//  ReadingAssembly.swift
//  Test
//

import Swinject
import Foundation
import Common

public final class ReadingAssembly: Assembly {
    private static let searchDBName = "search-index"

    public init(){}
    public func assemble(container: Container) {
        container.register(SQLiteDatabase.self) { _ in
            guard let path = Bundle.main.path(forResource: Self.searchDBName, ofType: "db") else {
                fatalError("ReadingAssembly: could not find \(Self.searchDBName).db in the app bundle. Check it's added to your target.")
            }
            do {
                return try SQLiteDatabase(path: path)
            } catch {
                fatalError("ReadingAssembly: failed to open \(Self.searchDBName).db — \(error.localizedDescription)")
            }
        }.inObjectScope(.container)

        container.register(QuranSearchRepository.self) { r in
            QuranSearchRepositoryImpl(db: r.resolve(SQLiteDatabase.self)!)
        }.inObjectScope(.container)

    }
}
