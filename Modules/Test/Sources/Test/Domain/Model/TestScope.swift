//
//  TestScope.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import Foundation

// MARK: - Scope the user is being tested on

enum TestScope: Equatable {
    case juz(Int)
    case surahRange(fromSurah: Int, toSurah: Int)
    case ayahRange(surah: Int, fromAyah: Int, toAyah: Int)

    var displayTitle: String {
        switch self {
        case .juz(let number):
            return "Juz' \(number)"
        case .surahRange(let from, let to):
            return from == to ? "Surah \(from)" : "Surahs \(from)–\(to)"
        case .ayahRange(let surah, let from, let to):
            return "Surah \(surah), Ayahs \(from)–\(to)"
        }
    }
}


struct AyahUnit: Equatable {
    let surah: Int
    let ayah: Int
    let firstWordId: Int
    let lastWordId: Int
}

struct ResolvedTestRange {
    let scope: TestScope
    let ayahUnits: [AyahUnit]
}

