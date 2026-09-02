//
//  PageBookmarkRepositoryImpl.swift
//  Bookmarks (Data)
//

import Foundation

final class PageBookmarkRepositoryImpl: PageBookmarkRepository {
    private let localDataSource: PageBookmarkLocalDataSourceProtocol

    @MainActor
    init(localDataSource: PageBookmarkLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    @MainActor func fetchAll() throws -> [PageBookmark] {
        PageBookmarkMapper.toDomain(try localDataSource.fetchAll())
    }

    @MainActor func add(pageNumber: Int, surahName: String, juzNumber: Int) throws {
        try localDataSource.add(pageNumber: pageNumber, surahName: surahName, juzNumber: juzNumber)
    }

    @MainActor func remove(pageNumber: Int) throws {
        try localDataSource.remove(pageNumber: pageNumber)
    }

    @MainActor func isBookmarked(pageNumber: Int) throws -> Bool {
        try localDataSource.isBookmarked(pageNumber: pageNumber)
    }
}
