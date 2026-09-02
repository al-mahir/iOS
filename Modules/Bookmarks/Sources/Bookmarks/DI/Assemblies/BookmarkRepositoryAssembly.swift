//
//  BookmarkRepositoryAssembly.swift
//  Bookmarks (DI)
//

import Swinject

/// Registers every Repository implementation, injecting data sources
/// that were registered by `BookmarkDataSourceAssembly`.
final class BookmarkRepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PageBookmarkRepository.self) { r in
            MainActor.assumeIsolated {
                PageBookmarkRepositoryImpl(
                    localDataSource: r.resolve(PageBookmarkLocalDataSourceProtocol.self)!
                )
            }
        }.inObjectScope(.container)

        container.register(AyahBookmarkRepository.self) { r in
            MainActor.assumeIsolated {
                AyahBookmarkRepositoryImpl(
                    localDataSource: r.resolve(AyahBookmarkLocalDataSourceProtocol.self)!
                )
            }
        }.inObjectScope(.container)

        container.register(SurahBookmarkRepository.self) { r in
            MainActor.assumeIsolated {
                SurahBookmarkRepositoryImpl(
                    localDataSource: r.resolve(SurahBookmarkLocalDataSourceProtocol.self)!
                )
            }
        }.inObjectScope(.container)

        container.register(SheikhBookmarkRepository.self) { r in
            MainActor.assumeIsolated {
                SheikhBookmarkRepositoryImpl(
                    localDataSource: r.resolve(SheikhBookmarkLocalDataSourceProtocol.self)!
                )
            }
        }.inObjectScope(.container)
    }
}

