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
            MainActor.assumeIsolated { PageBookmarkLocalDataSource(dao: PageBookmarkDAO(dataService: .shared)) }
        }.inObjectScope(.container)

        container.register(AyahBookmarkLocalDataSourceProtocol.self) { _ in
            MainActor.assumeIsolated { AyahBookmarkLocalDataSource(dao: AyahBookmarkDAO(dataService: .shared)) }
        }.inObjectScope(.container)

        container.register(SurahBookmarkLocalDataSourceProtocol.self) { _ in
            MainActor.assumeIsolated { SurahBookmarkLocalDataSource(dao: SurahBookmarkDAO(dataService: .shared)) }
        }.inObjectScope(.container)

        container.register(SheikhBookmarkLocalDataSourceProtocol.self) { _ in
            MainActor.assumeIsolated { SheikhBookmarkLocalDataSource(dao: SheikhBookmarkDAO(dataService: .shared)) }
        }.inObjectScope(.container)
    }
}
