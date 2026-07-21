//
//  QuranComResponseDTO.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Foundation

struct QuranComResponseDTO: Decodable {
    let verse: QuranVerseDTO
}

struct QuranVerseDTO: Decodable {
    let textUthmani: String?
    let translations: [QuranTranslationDTO]?
    let verseKey: String?
    let juzNumber: Int?
    let pageNumber: Int?

    enum CodingKeys: String, CodingKey {
        case textUthmani = "text_uthmani"
        case translations
        case verseKey = "verse_key"
        case juzNumber = "juz_number"
        case pageNumber = "page_number"
    }
}

struct QuranTranslationDTO: Decodable {
    let text: String?
}
