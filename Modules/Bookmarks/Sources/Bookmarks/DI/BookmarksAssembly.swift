//
//  BookmarksAssembly.swift
//  Bookmarks
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//


//
//  BookmarksAssembly.swift
//  Bookmarks (DI)
//

import Swinject

public final class BookmarksAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(SurahBookmarkUseCase.self) { _ in
            DefaultSurahBookmarkUseCase(repository: SurahBookmarkRepositoryImpl())
        }
        container.register(AyahBookmarkUseCase.self) { _ in
            DefaultAyahBookmarkUseCase(repository: AyahBookmarkRepositoryImpl())
        }
        container.register(PageBookmarkUseCase.self) { _ in
            DefaultPageBookmarkUseCase(repository: PageBookmarkRepositoryImpl())
        }
        container.register(SheikhBookmarkUseCase.self) { _ in
            DefaultSheikhBookmarkUseCase(repository: SheikhBookmarkRepositoryImpl())
        }
    }
}