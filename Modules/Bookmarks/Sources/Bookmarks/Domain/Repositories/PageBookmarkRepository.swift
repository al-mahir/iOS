//
//  PageBookmarkRepository.swift
//  Bookmarks (Domain)
//

import Foundation

protocol PageBookmarkRepository {
    @MainActor func fetchAll() throws -> [PageBookmark]
    @MainActor func add(pageNumber: Int, surahName: String, juzNumber: Int) throws
    @MainActor func remove(pageNumber: Int) throws
    @MainActor func isBookmarked(pageNumber: Int) throws -> Bool
}
