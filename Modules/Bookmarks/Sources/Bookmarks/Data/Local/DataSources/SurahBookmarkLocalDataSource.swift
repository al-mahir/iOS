//
//  SurahBookmarkLocalDataSource.swift
//  Bookmarks (Data)
//

import Foundation

protocol SurahBookmarkLocalDataSourceProtocol {
    func fetchAll() throws -> [SurahBookmarkEntity]
    func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws
    func remove(surahNumber: Int) throws
    func isBookmarked(surahNumber: Int) throws -> Bool
}

final class SurahBookmarkLocalDataSource: SurahBookmarkLocalDataSourceProtocol {
    private let dao: SurahBookmarkDAOProtocol

    @MainActor
    init(dao: SurahBookmarkDAOProtocol) {
        self.dao = dao
    }

    @MainActor
    func fetchAll() throws -> [SurahBookmarkEntity] {
        try dao.fetchAll(forUserID: CurrentUserProvider.userID).sorted { $0.dateAdded > $1.dateAdded }
    }

    @MainActor
    func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws {
        let userID = CurrentUserProvider.userID
        let id = SurahBookmarkEntity.makeID(userID: userID, surahNumber: surahNumber)
        guard try dao.fetchOne(id: id) == nil else { return }
        let entity = SurahBookmarkEntity(userID: userID, surahNumber: surahNumber, arabicName: arabicName, englishName: englishName, ayahCount: ayahCount, pageNumber: pageNumber)
        try dao.insert(entity)
    }

    @MainActor
    func remove(surahNumber: Int) throws {
        let id = SurahBookmarkEntity.makeID(userID: CurrentUserProvider.userID, surahNumber: surahNumber)
        try dao.delete(id: id)
    }

    @MainActor
    func isBookmarked(surahNumber: Int) throws -> Bool {
        let id = SurahBookmarkEntity.makeID(userID: CurrentUserProvider.userID, surahNumber: surahNumber)
        return try dao.fetchOne(id: id) != nil
    }
}
