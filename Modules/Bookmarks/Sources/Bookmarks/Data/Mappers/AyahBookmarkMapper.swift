//
//  AyahBookmarkMapper.swift
//  Bookmarks (Data)
//

import Foundation

enum AyahBookmarkMapper {
    static func toDomain(_ entity: AyahBookmarkEntity) -> AyahBookmark {
        AyahBookmark(surahNumber: entity.surahNumber, ayahNumber: entity.ayahNumber, arabicText: entity.arabicText, translation: entity.translation, surahName: entity.surahName, pageNumber: entity.pageNumber, dateAdded: entity.dateAdded)
    }

    static func toDomain(_ entities: [AyahBookmarkEntity]) -> [AyahBookmark] {
        entities.map(toDomain)
    }
}
