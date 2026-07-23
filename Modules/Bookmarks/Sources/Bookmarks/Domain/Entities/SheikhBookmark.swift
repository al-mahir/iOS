//
//  SheikhBookmark.swift
//  Bookmarks (Domain)
//

import Foundation

public struct SheikhBookmark: Identifiable, Equatable {
    public var id: String { sheikhID }
    public let sheikhID: String
    public let name: String
    public let arabicName: String
    public let reciterStyle: String
    public let dateAdded: Date
}
