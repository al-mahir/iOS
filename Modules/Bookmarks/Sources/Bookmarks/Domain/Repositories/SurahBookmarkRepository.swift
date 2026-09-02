//
//  SurahBookmarkRepository.swift
//  Bookmarks (Domain)
//

import Foundation

protocol SurahBookmarkRepository {
    @MainActor func fetchAll() throws -> [SurahBookmark]
    @MainActor func add(surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int) throws
    @MainActor func remove(surahNumber: Int) throws
    @MainActor func isBookmarked(surahNumber: Int) throws -> Bool
}
