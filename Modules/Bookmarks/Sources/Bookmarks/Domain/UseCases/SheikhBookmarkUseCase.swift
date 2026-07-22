//
//  SheikhBookmarkUseCase.swift
//  Bookmarks (Domain)
//

import Foundation

public protocol SheikhBookmarkUseCase {
    @MainActor func fetchAll() throws -> [SheikhBookmark]
    @MainActor func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws
    @MainActor func remove(sheikhID: String) throws
    @MainActor func isBookmarked(sheikhID: String) throws -> Bool
}

final class DefaultSheikhBookmarkUseCase: SheikhBookmarkUseCase {
    private let repository: SheikhBookmarkRepository

    init(repository: SheikhBookmarkRepository) {
        self.repository = repository
    }

    @MainActor func fetchAll() throws -> [SheikhBookmark] { try repository.fetchAll() }

    @MainActor func add(sheikhID: String, name: String, arabicName: String, reciterStyle: String) throws {
        try repository.add(sheikhID: sheikhID, name: name, arabicName: arabicName, reciterStyle: reciterStyle)
    }

    @MainActor func remove(sheikhID: String) throws { try repository.remove(sheikhID: sheikhID) }

    @MainActor func isBookmarked(sheikhID: String) throws -> Bool { try repository.isBookmarked(sheikhID: sheikhID) }
}

