//
//  Surah.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 25/07/2026.
//

import Foundation

struct Surah: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let arabicName: String
    let englishName: String
    let ayahCount: Int
    let revelationType: RevelationType
    let juzStart: Int
    let juzEnd: Int
    let pageStart: Int
    let pageEnd: Int

    enum RevelationType: String, Codable {
        case meccan = "Meccan"
        case medinan = "Medinan"

        var title: String {
            switch self {
            case .meccan:
                return String(localized: "Meccan", comment: "Revelation type: Meccan surah")
            case .medinan:
                return String(localized: "Medinan", comment: "Revelation type: Medinan surah")
            }
        }
    }

    /// Returns the appropriate name based on the user's primary language setting.
    var displayName: String {
        let languageCode = Locale.current.language.languageCode?.identifier
        return languageCode == "ar" ? arabicName : englishName
    }

    /// Formatted localized string for the total number of verses (e.g., "7 Ayahs" / "٧ آيات").
    var localizedAyahCount: String {
        let format = String(
            localized: "%d Verses",
            comment: "Format for total number of ayahs/verses in a Surah"
        )
        return String.localizedStringWithFormat(format, ayahCount)
    }
}
