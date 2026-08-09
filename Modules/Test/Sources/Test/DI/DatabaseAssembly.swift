//
//  DatabaseAssembly.swift
//  Test
//
//  Created by Alaa Ayman on 17/07/2026.
//

import Swinject
import Common

public final class DatabaseAssembly: Assembly {
    public init(){}
    public func assemble(container: Container) {
        container.register(MushafDatabaseManager?.self) { _ in
            try? MushafDatabaseManager()
        }.inObjectScope(.container)

        container.register(WordsDAO?.self) { r in
            guard let manager = r.resolve(MushafDatabaseManager?.self) ?? nil else { return nil }
            return WordsDAO(db: manager.wordsDB)
        }

        container.register(LayoutDAO?.self) { r in
            guard let manager = r.resolve(MushafDatabaseManager?.self) ?? nil else { return nil }
            return LayoutDAO(db: manager.layoutDB)
        }
    }
}
