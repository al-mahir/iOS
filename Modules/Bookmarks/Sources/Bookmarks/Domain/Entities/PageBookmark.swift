//
//  PageBookmark.swift
//  Bookmarks (Domain)
//

import Foundation

public struct PageBookmark: Identifiable, Equatable {
    public var id: Int { pageNumber }
    public let pageNumber: Int
    public let surahName: String
    public let juzNumber: Int
    public let dateAdded: Date
}
