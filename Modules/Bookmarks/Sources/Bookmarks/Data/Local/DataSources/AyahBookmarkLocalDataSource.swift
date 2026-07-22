//
//  AyahBookmarkLocalDataSource.swift
//  Bookmarks (Data)
//

import Foundation

protocol AyahBookmarkLocalDataSourceProtocol {
    func fetchAll() throws -> [AyahBookmarkEntity]
    func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws
    func remove(surahNumber: Int, ayahNumber: Int) throws
    func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool
}

final class AyahBookmarkLocalDataSource: AyahBookmarkLocalDataSourceProtocol {
    private let dao: AyahBookmarkDAOProtocol

    init(dao: AyahBookmarkDAOProtocol = AyahBookmarkDAO()) {
        self.dao = dao
    }

    @MainActor
    func fetchAll() throws -> [AyahBookmarkEntity] {
        try dao.fetchAll(forUserID: CurrentUserProvider.userID).sorted { $0.dateAdded > $1.dateAdded }
    }

    @MainActor
    func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws {
        let userID = CurrentUserProvider.userID
        let id = AyahBookmarkEntity.makeID(userID: userID, surahNumber: surahNumber, ayahNumber: ayahNumber)
        guard try dao.fetchOne(id: id) == nil else { return }
        let entity = AyahBookmarkEntity(userID: userID, surahNumber: surahNumber, ayahNumber: ayahNumber, arabicText: arabicText, translation: translation, surahName: surahName, pageNumber: pageNumber)
        try dao.insert(entity)
    }

    @MainActor
    func remove(surahNumber: Int, ayahNumber: Int) throws {
        let id = AyahBookmarkEntity.makeID(userID: CurrentUserProvider.userID, surahNumber: surahNumber, ayahNumber: ayahNumber)
        try dao.delete(id: id)
    }

    @MainActor
    func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool {
        let id = AyahBookmarkEntity.makeID(userID: CurrentUserProvider.userID, surahNumber: surahNumber, ayahNumber: ayahNumber)
        return try dao.fetchOne(id: id) != nil
    }
}
