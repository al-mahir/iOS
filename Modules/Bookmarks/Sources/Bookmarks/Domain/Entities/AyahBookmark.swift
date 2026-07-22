//
//  AyahBookmark.swift
//  Bookmarks (Domain)
//

import Foundation

public struct AyahBookmark: Identifiable, Equatable {
    public var id: String { "\(surahNumber):\(ayahNumber)" }
    public let surahNumber: Int
    public let ayahNumber: Int
    public let arabicText: String
    public let translation: String
    public let surahName: String
    public let pageNumber: Int
    public let dateAdded: Date
}
