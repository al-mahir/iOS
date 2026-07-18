//
//  DataSourceAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Swinject

final class DataSourceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafLocalDataSource?.self) { r in
            guard
                let wordsDAO = r.resolve(WordsDAO?.self) ?? nil,
                let pagesDAO = r.resolve(PagesDAO?.self) ?? nil
            else { return nil }
            return MushafLocalDataSourceImpl(wordsDAO: wordsDAO, pagesDAO: pagesDAO)
        }.inObjectScope(.container)
    }
}
