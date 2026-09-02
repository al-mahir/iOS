//
//  SheikhBookmarkEntity.swift
//  Bookmarks (Data)
//
import Foundation
import SwiftData

@Model
public final class SheikhBookmarkEntity {
    @Attribute(.unique) public var id: String
    public var userID: String
    public var sheikhID: String
    public var name: String
    public var arabicName: String
    public var reciterStyle: String
    public var dateAdded: Date

    public init(userID: String, sheikhID: String, name: String, arabicName: String, reciterStyle: String, dateAdded: Date = .now) {
        self.id = SheikhBookmarkEntity.makeID(userID: userID, sheikhID: sheikhID)
        self.userID = userID
        self.sheikhID = sheikhID
        self.name = name
        self.arabicName = arabicName
        self.reciterStyle = reciterStyle
        self.dateAdded = dateAdded
    }

    public static func makeID(userID: String, sheikhID: String) -> String {
        "\(userID)_sheikh_\(sheikhID)"
    }
}

extension SheikhBookmarkEntity: Identifiable {}
