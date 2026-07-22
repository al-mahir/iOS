//
//  PageBookmarkLocalDataSource.swift
//  Bookmarks (Data)
//

import Foundation

protocol PageBookmarkLocalDataSourceProtocol {
    func fetchAll() throws -> [PageBookmarkEntity]
    func add(pageNumber: Int, surahName: String, juzNumber: Int) throws
    func remove(pageNumber: Int) throws
    func isBookmarked(pageNumber: Int) throws -> Bool
}

final class PageBookmarkLocalDataSource: PageBookmarkLocalDataSourceProtocol {
    private let dao: PageBookmarkDAOProtocol

    init(dao: PageBookmarkDAOProtocol = PageBookmarkDAO()) {
        self.dao = dao
    }

    @MainActor
    func fetchAll() throws -> [PageBookmarkEntity] {
        try dao.fetchAll(forUserID: CurrentUserProvider.userID).sorted { $0.dateAdded > $1.dateAdded }
    }

    @MainActor
    func add(pageNumber: Int, surahName: String, juzNumber: Int) throws {
        let userID = CurrentUserProvider.userID
        let id = PageBookmarkEntity.makeID(userID: userID, pageNumber: pageNumber)
        guard try dao.fetchOne(id: id) == nil else { return }
        let entity = PageBookmarkEntity(userID: userID, pageNumber: pageNumber, surahName: surahName, juzNumber: juzNumber)
        try dao.insert(entity)
    }

    @MainActor
    func remove(pageNumber: Int) throws {
        let id = PageBookmarkEntity.makeID(userID: CurrentUserProvider.userID, pageNumber: pageNumber)
        try dao.delete(id: id)
    }

    @MainActor
    func isBookmarked(pageNumber: Int) throws -> Bool {
        let id = PageBookmarkEntity.makeID(userID: CurrentUserProvider.userID, pageNumber: pageNumber)
        return try dao.fetchOne(id: id) != nil
    }
}
