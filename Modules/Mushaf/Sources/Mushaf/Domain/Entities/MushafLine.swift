//
//  MushafLine.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import Foundation


enum MushafLineType: String {
    case ayah
    case surahName = "surah_name"
    case basmallah
}

struct MushafLine: Identifiable, Hashable {
    let id: Int
    let lineType: MushafLineType
    let isCentered: Bool
    let surahNumber: Int?
    let words: [QuranWord]
}
