//
//  DatabaseAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//


import Swinject


final class DatabaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafDatabaseManager?.self) { _ in
            try? MushafDatabaseManager()
        }.inObjectScope(.container)

        container.register(WordsDAO?.self) { r in
            guard let manager = r.resolve(MushafDatabaseManager?.self) ?? nil else { return nil }
            return WordsDAO(db: manager.wordsDB)
        }

        container.register(PagesDAO?.self) { r in
            guard let manager = r.resolve(MushafDatabaseManager?.self) ?? nil else { return nil }
            return PagesDAO(db: manager.layoutDB)
        }
 
        container.register(SearchDAO?.self) { r in
            guard
                let manager = r.resolve(MushafDatabaseManager?.self) ?? nil,
                let searchDB = manager.searchDB
            else { return nil }
            return SearchDAO(db: searchDB)
        }
    }
}