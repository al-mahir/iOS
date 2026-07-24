//
//  MushafLine.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import Foundation




public enum MushafLineType: String {
    case ayah
    case surahName = "surah_name"
    case basmallah
}

public struct MushafLine: Identifiable, Hashable {
    public let id: Int
    public let lineType: MushafLineType
    public let isCentered: Bool
    public let surahNumber: Int?
    public let words: [QuranWord]
}

