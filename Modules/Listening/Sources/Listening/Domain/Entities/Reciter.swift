//
//  Reciter.swift
//  Listening
//

import Foundation

/// Domain entity representing a Quran reciter available on Quran.com
public struct Reciter: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let arabicName: String
    public let style: String?
    public let translatedName: String?

    public init(
        id: Int,
        name: String,
        arabicName: String,
        style: String?,
        translatedName: String?
    ) {
        self.id = id
        self.name = name
        self.arabicName = arabicName
        self.style = style
        self.translatedName = translatedName
    }

    /// Display name: translated name if available, otherwise reciter name
    public var displayName: String {
        translatedName ?? name
    }

    /// Short style badge, e.g. "Murattal", "Mujawwad"
    public var styleBadge: String? {
        style?.capitalized
    }
}
