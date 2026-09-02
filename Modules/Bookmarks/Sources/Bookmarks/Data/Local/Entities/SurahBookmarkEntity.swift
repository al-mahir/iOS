//
//  SurahBookmarkEntity.swift
//  Bookmarks (Data)
//
import Foundation
import SwiftData

@Model
public final class SurahBookmarkEntity {
    @Attribute(.unique) public var id: String
    public var userID: String
    public var surahNumber: Int
    public var arabicName: String
    public var englishName: String
    public var ayahCount: Int
    public var pageNumber: Int
    public var dateAdded: Date

    public init(userID: String, surahNumber: Int, arabicName: String, englishName: String, ayahCount: Int, pageNumber: Int, dateAdded: Date = .now) {
        self.id = SurahBookmarkEntity.makeID(userID: userID, surahNumber: surahNumber)
        self.userID = userID
        self.surahNumber = surahNumber
        self.arabicName = arabicName
        self.englishName = englishName
        self.ayahCount = ayahCount
        self.pageNumber = pageNumber
        self.dateAdded = dateAdded
    }

    public static func makeID(userID: String, surahNumber: Int) -> String {
        "\(userID)_surah_\(surahNumber)"
    }
}

extension SurahBookmarkEntity: Identifiable {}
