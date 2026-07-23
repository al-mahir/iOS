//
//  SurahBookmark.swift
//  Bookmarks (Domain)
//

import Foundation

public struct SurahBookmark: Identifiable, Equatable {
    public var id: Int { surahNumber }
    public let surahNumber: Int
    public let arabicName: String
    public let englishName: String
    public let ayahCount: Int
    public let pageNumber: Int
    public let dateAdded: Date
}
