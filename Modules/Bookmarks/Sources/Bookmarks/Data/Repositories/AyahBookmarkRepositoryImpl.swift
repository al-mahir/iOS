//
//  AyahBookmarkRepositoryImpl.swift
//  Bookmarks (Data)
//

import Foundation

final class AyahBookmarkRepositoryImpl: AyahBookmarkRepository {
    private let localDataSource: AyahBookmarkLocalDataSourceProtocol

    @MainActor
    init(localDataSource: AyahBookmarkLocalDataSourceProtocol) {
        self.localDataSource = localDataSource
    }

    @MainActor func fetchAll() throws -> [AyahBookmark] {
        AyahBookmarkMapper.toDomain(try localDataSource.fetchAll())
    }

    @MainActor func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws {
        try localDataSource.add(surahNumber: surahNumber, ayahNumber: ayahNumber, arabicText: arabicText, translation: translation, surahName: surahName, pageNumber: pageNumber)
    }

    @MainActor func remove(surahNumber: Int, ayahNumber: Int) throws {
        try localDataSource.remove(surahNumber: surahNumber, ayahNumber: ayahNumber)
    }

    @MainActor func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool {
        try localDataSource.isBookmarked(surahNumber: surahNumber, ayahNumber: ayahNumber)
    }
}

