//
//  AyahBookmarkRepository.swift
//  Bookmarks (Domain)
//

import Foundation

protocol AyahBookmarkRepository {
    @MainActor func fetchAll() throws -> [AyahBookmark]
    @MainActor func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws
    @MainActor func remove(surahNumber: Int, ayahNumber: Int) throws
    @MainActor func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool
}
