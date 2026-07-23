//
//  SheikhBookmarkLocalDataSource.swift
//  Bookmarks (Data)
//

import Foundation

protocol SheikhBookmarkLocalDataSourceProtocol {
    func fetchAll() throws -> [SheikhBookmarkEntity]
    func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws
    func remove(sheikhID: String) throws
    func isBookmarked(sheikhID: String) throws -> Bool
}

final class SheikhBookmarkLocalDataSource: SheikhBookmarkLocalDataSourceProtocol {
    private let dao: SheikhBookmarkDAOProtocol

    @MainActor
    init(dao: SheikhBookmarkDAOProtocol) {
        self.dao = dao
    }

    @MainActor
    func fetchAll() throws -> [SheikhBookmarkEntity] {
        try dao.fetchAll(forUserID: CurrentUserProvider.userID).sorted { $0.dateAdded > $1.dateAdded }
    }

    @MainActor
    func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws {
        let userID = CurrentUserProvider.userID
        let id = SheikhBookmarkEntity.makeID(userID: userID, sheikhID: sheikhID)
        guard try dao.fetchOne(id: id) == nil else { return }
        let entity = SheikhBookmarkEntity(userID: userID, sheikhID: sheikhID, name: name, arabicName: arabicName, reciterStyle: reciterStyle)
        try dao.insert(entity)
    }

    @MainActor
    func remove(sheikhID: String) throws {
        let id = SheikhBookmarkEntity.makeID(userID: CurrentUserProvider.userID, sheikhID: sheikhID)
        try dao.delete(id: id)
    }

    @MainActor
    func isBookmarked(sheikhID: String) throws -> Bool {
        let id = SheikhBookmarkEntity.makeID(userID: CurrentUserProvider.userID, sheikhID: sheikhID)
        return try dao.fetchOne(id: id) != nil
    }
}
