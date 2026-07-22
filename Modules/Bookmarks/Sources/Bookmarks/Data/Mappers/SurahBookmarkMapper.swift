//
//  SurahBookmarkMapper.swift
//  Bookmarks (Data)
//

import Foundation

enum SurahBookmarkMapper {
    static func toDomain(_ entity: SurahBookmarkEntity) -> SurahBookmark {
        SurahBookmark(surahNumber: entity.surahNumber, arabicName: entity.arabicName, englishName: entity.englishName, ayahCount: entity.ayahCount, pageNumber: entity.pageNumber, dateAdded: entity.dateAdded)
    }

    static func toDomain(_ entities: [SurahBookmarkEntity]) -> [SurahBookmark] {
        entities.map(toDomain)
    }
}
