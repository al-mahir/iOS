//
//  AyahBookmarkEntity.swift
//  Bookmarks (Data)
//
import Foundation
import SwiftData

@Model
public final class AyahBookmarkEntity {
    @Attribute(.unique) public var id: String
    public var userID: String
    public var surahNumber: Int
    public var ayahNumber: Int
    public var arabicText: String
    public var translation: String
    public var surahName: String
    public var pageNumber: Int
    public var dateAdded: Date

    public init(userID: String, surahNumber: Int, ayahNumber: Int, arabicText: String, translation: String, surahName: String, pageNumber: Int, dateAdded: Date = .now) {
        self.id = AyahBookmarkEntity.makeID(userID: userID, surahNumber: surahNumber, ayahNumber: ayahNumber)
        self.userID = userID
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.arabicText = arabicText
        self.translation = translation
        self.surahName = surahName
        self.pageNumber = pageNumber
        self.dateAdded = dateAdded
    }

    public static func makeID(userID: String, surahNumber: Int, ayahNumber: Int) -> String {
        "\(userID)_ayah_\(surahNumber)_\(ayahNumber)"
    }
}

// Identifiable conformance is inherited as public if the model is public
extension AyahBookmarkEntity: Identifiable {}
