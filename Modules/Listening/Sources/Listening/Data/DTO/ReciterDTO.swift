//
//  ReciterDTO.swift
//  Listening
//

import Foundation

// MARK: - Reciter List Response

/// Top-level response from GET /api/v4/resources/recitations
struct RecitersResponseDTO: Decodable {
    let recitations: [ReciterDTO]
}

/// Single reciter entry
struct ReciterDTO: Decodable {
    let id: Int
    let reciterName: String
    let style: String?
    let translatedName: TranslatedNameDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case reciterName     = "reciter_name"
        case style
        case translatedName  = "translated_name"
    }
}

struct TranslatedNameDTO: Decodable {
    let name: String?
    let languageName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case languageName = "language_name"
    }
}

// MARK: - Chapter Audio Response

/// Top-level response from GET /api/v4/chapter_recitations/{reciter_id}/{chapter_number}
struct ChapterAudioResponseDTO: Decodable {
    let audioFile: AudioFileDTO?

    enum CodingKeys: String, CodingKey {
        case audioFile = "audio_file"
    }
}

struct AudioFileDTO: Decodable {
    let chapterID: Int
    let fileSize: Double?
    let format: String?
    let audioURL: String
    let timestamps: [VerseTimestampDTO]?

    enum CodingKeys: String, CodingKey {
        case chapterID  = "chapter_id"
        case fileSize   = "file_size"
        case format
        case audioURL   = "audio_url"
        case timestamps
    }
}

/// Verse-level timestamp block returned when `segments=true`
struct VerseTimestampDTO: Decodable {
    let verseKey: String
    let timestampFrom: Int
    let timestampTo: Int
    let segments: [[Int]]?

    enum CodingKeys: String, CodingKey {
        case verseKey       = "verse_key"
        case timestampFrom  = "timestamp_from"
        case timestampTo    = "timestamp_to"
        case segments
    }
}
