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
            MainActor.assumeIsolated {
                DefaultSurahBookmarkUseCase(
                    repository: SurahBookmarkRepositoryImpl(
                        localDataSource: SurahBookmarkLocalDataSource(
                            dao: SurahBookmarkDAO(dataService: .shared)
                        )
                    )
                )
            }
        }
        container.register(AyahBookmarkUseCase.self) { _ in
            MainActor.assumeIsolated {
                DefaultAyahBookmarkUseCase(
                    repository: AyahBookmarkRepositoryImpl(
                        localDataSource: AyahBookmarkLocalDataSource(
                            dao: AyahBookmarkDAO(dataService: .shared)
                        )
                    )
                )
            }
        }
        container.register(PageBookmarkUseCase.self) { _ in
            MainActor.assumeIsolated {
                DefaultPageBookmarkUseCase(
                    repository: PageBookmarkRepositoryImpl(
                        localDataSource: PageBookmarkLocalDataSource(
                            dao: PageBookmarkDAO(dataService: .shared)
                        )
                    )
                )
            }
        }
        container.register(SheikhBookmarkUseCase.self) { _ in
            MainActor.assumeIsolated {
                DefaultSheikhBookmarkUseCase(
                    repository: SheikhBookmarkRepositoryImpl(
                        localDataSource: SheikhBookmarkLocalDataSource(
                            dao: SheikhBookmarkDAO(dataService: .shared)
                        )
                    )
                )
            }
        }
    }
}