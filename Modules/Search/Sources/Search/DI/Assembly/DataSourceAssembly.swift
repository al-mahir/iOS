//
//  DataSourceAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//


import Swinject
final class DataSourceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafSearchLocalDataSource?.self) { r in
            guard
                let searchDAO = r.resolve(SearchDAO?.self) ?? nil,
                let pagesDAO = r.resolve(PagesDAO?.self) ?? nil
            else { return nil }
            return MushafSearchLocalDataSourceImpl(searchDAO: searchDAO, pagesDAO: pagesDAO)
        }.inObjectScope(.container)
    }
}
