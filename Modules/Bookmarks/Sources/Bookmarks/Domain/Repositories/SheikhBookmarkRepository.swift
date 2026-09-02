//
//  SheikhBookmarkRepository.swift
//  Bookmarks (Domain)
//

import Foundation

protocol SheikhBookmarkRepository {
    @MainActor func fetchAll() throws -> [SheikhBookmark]
    @MainActor func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws
    @MainActor func remove(sheikhID: String) throws
    @MainActor func isBookmarked(sheikhID: String) throws -> Bool
}
