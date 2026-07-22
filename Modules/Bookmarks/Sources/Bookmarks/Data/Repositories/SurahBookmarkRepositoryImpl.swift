//
//  SurahBookmarkRepositoryImpl.swift
//  Bookmarks (Data)
//

import Foundation

final class SurahBookmarkRepositoryImpl: SurahBookmarkRepository {
    private let localDataSource: SurahBookmarkLocalDataSourceProtocol

    init(localDataSource: SurahBookmarkLocalDataSourceProtocol = SurahBookmarkLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    @MainActor func fetchAll() throws -> [SurahBookmark] {
        SurahBookmarkMapper.toDomain(try localDataSource.fetchAll())
    }

    @MainActor func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws {
        try localDataSource.add(surahNumber: surahNumber, arabicName: arabicName, englishName: englishName, ayahCount: ayahCount, pageNumber: pageNumber)
    }

    @MainActor func remove(surahNumber: Int) throws {
        try localDataSource.remove(surahNumber: surahNumber)
    }

    @MainActor func isBookmarked(surahNumber: Int) throws -> Bool {
        try localDataSource.isBookmarked(surahNumber: surahNumber)
    }
}
