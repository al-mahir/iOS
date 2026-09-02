//
//  BookmarkUseCaseAssembly.swift
//  Bookmarks (DI)
//

import Swinject

/// Registers every UseCase implementation, injecting repositories
/// that were registered by `BookmarkRepositoryAssembly`.
///
/// NOTE: `BookmarksAssembly` (public) is kept separately for use inside
/// Mushaf's `DIContainer`. This internal assembly is used only by
/// `BookmarksDependencyContainer` for the Bookmarks tab.
final class BookmarkUseCaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(PageBookmarkUseCase.self) { r in
            DefaultPageBookmarkUseCase(
                repository: r.resolve(PageBookmarkRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(AyahBookmarkUseCase.self) { r in
            DefaultAyahBookmarkUseCase(
                repository: r.resolve(AyahBookmarkRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(SurahBookmarkUseCase.self) { r in
            DefaultSurahBookmarkUseCase(
                repository: r.resolve(SurahBookmarkRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(SheikhBookmarkUseCase.self) { r in
            DefaultSheikhBookmarkUseCase(
                repository: r.resolve(SheikhBookmarkRepository.self)!
            )
        }.inObjectScope(.container)
    }
}
