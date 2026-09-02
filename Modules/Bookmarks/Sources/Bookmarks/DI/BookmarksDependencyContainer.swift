//
//  BookmarksDependencyContainer.swift
//  Bookmarks (DI)
//

import Foundation
import Swinject

/// The only public entry-point for Bookmarks-tab composition.
///
/// Internally wires everything through Swinject assemblies, matching the
/// pattern used in the Mushaf module's `DIContainer`. Three layers:
///   BookmarkDataSourceAssembly → BookmarkRepositoryAssembly → BookmarkUseCaseAssembly
///
/// `ObservableObject` conformance lets `MainTabView` hold this as `@StateObject`
/// so the container (and its SwiftData-backed use-cases) lives exactly once.
public final class BookmarksDependencyContainer: ObservableObject {

    private let container: Container

    public init() {
        let c = Container()
        _ = Assembler(
            [
                BookmarkDataSourceAssembly(),
                BookmarkRepositoryAssembly(),
                BookmarkUseCaseAssembly(),
            ],
            container: c
        )
        container = c
    }

    // MARK: - Factory

    /// No @MainActor needed here — BookmarksViewModel.init() is a plain
    /// synchronous init and this is called from BookmarksView.init() which
    /// is not guaranteed to run on the MainActor.
    @MainActor func makeBookmarksViewModel() -> BookmarksViewModel {
        BookmarksViewModel(
            surahBookmarkUseCase:  container.resolve(SurahBookmarkUseCase.self)!,
            ayahBookmarkUseCase:   container.resolve(AyahBookmarkUseCase.self)!,
            pageBookmarkUseCase:   container.resolve(PageBookmarkUseCase.self)!,
            sheikhBookmarkUseCase: container.resolve(SheikhBookmarkUseCase.self)!
        )
    }
}
