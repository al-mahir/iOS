//
//  SheikhBookmarkMapper.swift
//  Bookmarks (Data)
//

import Foundation

enum SheikhBookmarkMapper {
    static func toDomain(_ entity: SheikhBookmarkEntity) -> SheikhBookmark {
        SheikhBookmark(sheikhID: entity.sheikhID, name: entity.name, arabicName: entity.arabicName, reciterStyle: entity.reciterStyle, dateAdded: entity.dateAdded)
    }

    static func toDomain(_ entities: [SheikhBookmarkEntity]) -> [SheikhBookmark] {
        entities.map(toDomain)
    }
}
