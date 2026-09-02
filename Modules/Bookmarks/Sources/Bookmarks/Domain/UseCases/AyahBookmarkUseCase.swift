//
//  AyahBookmarkUseCase.swift
//  Bookmarks (Domain)
//

import Foundation

public protocol AyahBookmarkUseCase {
    @MainActor func fetchAll() throws -> [AyahBookmark]
    @MainActor func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws
    @MainActor func remove(surahNumber: Int, ayahNumber: Int) throws
    @MainActor func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool
}

final class DefaultAyahBookmarkUseCase: AyahBookmarkUseCase {
    private let repository: AyahBookmarkRepository

    init(repository: AyahBookmarkRepository) {
        self.repository = repository
    }

    @MainActor func fetchAll() throws -> [AyahBookmark] { try repository.fetchAll() }

    @MainActor func add(surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int) throws {
        try repository.add(surahNumber: surahNumber, ayahNumber: ayahNumber, arabicText: arabicText, translation: translation, surahName: surahName, pageNumber: pageNumber)
    }

    @MainActor func remove(surahNumber: Int, ayahNumber: Int) throws {
        try repository.remove(surahNumber: surahNumber, ayahNumber: ayahNumber)
    }

    @MainActor func isBookmarked(surahNumber: Int, ayahNumber: Int) throws -> Bool {
        try repository.isBookmarked(surahNumber: surahNumber, ayahNumber: ayahNumber)
    }
}

