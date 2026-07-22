//
//  PageBookmarkEntity.swift
//  Bookmarks (Data)
//

import Foundation
import SwiftData

@Model
public final class PageBookmarkEntity {
    @Attribute(.unique) public var id: String
    public var userID: String
    public var pageNumber: Int
    public var surahName: String
    public var juzNumber: Int
    public var dateAdded: Date

    public init(userID: String, pageNumber: Int, surahName: String, juzNumber: Int, dateAdded: Date = .now) {
        self.id = PageBookmarkEntity.makeID(userID: userID, pageNumber: pageNumber)
        self.userID = userID
        self.pageNumber = pageNumber
        self.surahName = surahName
        self.juzNumber = juzNumber
        self.dateAdded = dateAdded
    }

    public static func makeID(userID: String, pageNumber: Int) -> String {
        "\(userID)_page_\(pageNumber)"
    }
}

extension PageBookmarkEntity: Identifiable {}
