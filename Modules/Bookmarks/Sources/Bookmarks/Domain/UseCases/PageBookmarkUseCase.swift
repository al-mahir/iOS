//
//  PageBookmarkUseCase.swift
//  Bookmarks (Domain)
//

import Foundation

public protocol PageBookmarkUseCase {
    @MainActor func fetchAll() throws -> [PageBookmark]
    @MainActor func add(pageNumber: Int, surahName: String, juzNumber: Int) throws
    @MainActor func remove(pageNumber: Int) throws
    @MainActor func isBookmarked(pageNumber: Int) throws -> Bool
}

final class DefaultPageBookmarkUseCase: PageBookmarkUseCase {
    private let repository: PageBookmarkRepository

    init(repository: PageBookmarkRepository) {
        self.repository = repository
    }

    @MainActor func fetchAll() throws -> [PageBookmark] { try repository.fetchAll() }

    @MainActor func add(pageNumber: Int, surahName: String, juzNumber: Int) throws {
        try repository.add(pageNumber: pageNumber, surahName: surahName, juzNumber: juzNumber)
    }

    @MainActor func remove(pageNumber: Int) throws { try repository.remove(pageNumber: pageNumber) }

    @MainActor func isBookmarked(pageNumber: Int) throws -> Bool { try repository.isBookmarked(pageNumber: pageNumber) }
}

