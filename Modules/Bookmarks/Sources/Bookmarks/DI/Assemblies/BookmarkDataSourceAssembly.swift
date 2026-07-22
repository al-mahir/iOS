//
//  BookmarkDataSourceAssembly.swift
//  Bookmarks (DI)
//

import Swinject

/// Registers every LocalDataSource concrete type.
/// Each data source is scoped to the container (shared singleton within one
/// `BookmarksDependencyContainer` instance).
final class BookmarkDataSourceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PageBookmarkLocalDataSourceProtocol.self) { _ in
            PageBookmarkLocalDataSource()
        }.inObjectScope(.container)

        container.register(AyahBookmarkLocalDataSourceProtocol.self) { _ in
            AyahBookmarkLocalDataSource()
        }.inObjectScope(.container)

        container.register(SurahBookmarkLocalDataSourceProtocol.self) { _ in
            SurahBookmarkLocalDataSource()
        }.inObjectScope(.container)

        container.register(SheikhBookmarkLocalDataSourceProtocol.self) { _ in
            SheikhBookmarkLocalDataSource()
        }.inObjectScope(.container)
    }
}
