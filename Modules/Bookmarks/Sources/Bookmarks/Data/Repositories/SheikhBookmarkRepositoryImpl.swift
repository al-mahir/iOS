//
//  SheikhBookmarkRepositoryImpl.swift
//  Bookmarks (Data)
//

import Foundation

final class SheikhBookmarkRepositoryImpl: SheikhBookmarkRepository {
    private let localDataSource: SheikhBookmarkLocalDataSourceProtocol

    init(localDataSource: SheikhBookmarkLocalDataSourceProtocol = SheikhBookmarkLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    @MainActor func fetchAll() throws -> [SheikhBookmark] {
        SheikhBookmarkMapper.toDomain(try localDataSource.fetchAll())
    }

    @MainActor func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws {
        try localDataSource.add(sheikhID: sheikhID, name: name, arabicName: arabicName, reciterStyle: reciterStyle)
    }

    @MainActor func remove(sheikhID: String) throws {
        try localDataSource.remove(sheikhID: sheikhID)
    }

    @MainActor func isBookmarked(sheikhID: String) throws -> Bool {
        try localDataSource.isBookmarked(sheikhID: sheikhID)
    }
}
