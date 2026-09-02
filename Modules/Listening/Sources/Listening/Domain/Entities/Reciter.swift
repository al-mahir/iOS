//
//  Reciter.swift
//  Listening
//

import Foundation
import Common

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

    /// Localized display name (Arabic name when Arabic is selected, otherwise displayName)
    public var localizedName: String {
        if AppLanguage.isArabicActive {
            return arabicName.isEmpty ? displayName : arabicName
        }
        return displayName
    }

    /// Short style badge, e.g. "Murattal", "Mujawwad"
    public var styleBadge: String? {
        style?.capitalized
    }

    /// Localized style badge
    public var localizedStyleBadge: String? {
        guard let s = style?.lowercased() else { return nil }
        if AppLanguage.isArabicActive {
            if s.contains("murattal") || s.contains("مرتل") { return "مرتل" }
            if s.contains("mujawwad") || s.contains("مجود") { return "مجود" }
            if s.contains("muallim") || s.contains("معلم") { return "معلم" }
            return style?.capitalized
        } else {
            if s.contains("مرتل") || s.contains("murattal") { return "Murattal" }
            if s.contains("مجود") || s.contains("mujawwad") { return "Mujawwad" }
            if s.contains("معلم") || s.contains("muallim") { return "Muallim" }
            return style?.capitalized
        }
    }
}
