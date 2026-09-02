//
//  PageBookmarkMapper.swift
//  Bookmarks (Data)
//

import Foundation

enum PageBookmarkMapper {
    static func toDomain(_ entity: PageBookmarkEntity) -> PageBookmark {
        PageBookmark(pageNumber: entity.pageNumber, surahName: entity.surahName, juzNumber: entity.juzNumber, dateAdded: entity.dateAdded)
    }

    static func toDomain(_ entities: [PageBookmarkEntity]) -> [PageBookmark] {
        entities.map(toDomain)
    }
}
