//
//  DatabaseAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
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
    }
}
