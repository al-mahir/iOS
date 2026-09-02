//
//  SurahBookmarkUseCase.swift
//  Bookmarks (Domain)
//

import Foundation

/// NOTE: bundles the 4 operations for this bookmark type in one use case rather
/// than 4 separate single-verb files — a pragmatic choice given there are 4
/// bookmark types × 4 verbs. Split into FetchSurahBookmarksUseCase /
/// AddSurahBookmarkUseCase / etc. if you'd rather keep strictly one verb per file.
public protocol SurahBookmarkUseCase {
    @MainActor func fetchAll() throws -> [SurahBookmark]
    @MainActor func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws
    @MainActor func remove(surahNumber: Int) throws
    @MainActor func isBookmarked(surahNumber: Int) throws -> Bool
}

final class DefaultSurahBookmarkUseCase: SurahBookmarkUseCase {
    private let repository: SurahBookmarkRepository

    init(repository: SurahBookmarkRepository) {
        self.repository = repository
    }

    @MainActor func fetchAll() throws -> [SurahBookmark] { try repository.fetchAll() }

    @MainActor func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws {
        try repository.add(surahNumber: surahNumber, arabicName: arabicName, englishName: englishName, ayahCount: ayahCount, pageNumber: pageNumber)
    }

    @MainActor func remove(surahNumber: Int) throws { try repository.remove(surahNumber: surahNumber) }

    @MainActor func isBookmarked(surahNumber: Int) throws -> Bool { try repository.isBookmarked(surahNumber: surahNumber) }
}

