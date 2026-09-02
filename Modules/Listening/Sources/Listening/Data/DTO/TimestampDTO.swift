//
//  TimestampDTO.swift
//  Listening
//

import Foundation

// MARK: - Word Timestamp Response

/// Top-level response from GET /api/v4/recitations/{reciter_id}/by_chapter/{chapter_number}
struct WordTimingsResponseDTO: Decodable {
    let audioFiles: [AudioSegmentDTO]

    enum CodingKeys: String, CodingKey {
        case audioFiles = "audio_files"
    }
}

/// One audio segment corresponding to a single ayah word
struct AudioSegmentDTO: Decodable {
    let verseKey: String      // e.g. "1:1"
    let wordPosition: Int     // 1-based word index within the ayah
    let audioURL: String?     // optional per-word audio (we use chapter-level stream)
    let timestampFrom: Int?   // start time in milliseconds
    let timestampTo: Int?     // end time in milliseconds

    enum CodingKeys: String, CodingKey {
        case verseKey       = "verse_key"
        case wordPosition   = "word_position"
        case audioURL       = "audio_url"
        case timestampFrom  = "timestamp_from"
        case timestampTo    = "timestamp_to"
    }
}
