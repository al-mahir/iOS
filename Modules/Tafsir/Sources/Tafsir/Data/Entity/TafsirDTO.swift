//
//  TafsirDTO.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import Foundation

struct TafsirAvailableDTO: Decodable {
    let tafsirKey: String
    let displayName: String
    let language: String
    let languageName: String
    let downloadUrl: String
    let fileSizeBytes: Int64
}

// → GET /api/tafsir
struct AyahTafsirDTO: Decodable {
    let surah: Int
    let ayah: Int
    let text: String
}

// MARK: - Mapping

extension TafsirAvailableDTO {
    func toDomain(isDownloaded: Bool) -> TafsirInfo {
        TafsirInfo(
            tafsirKey: tafsirKey,
            displayName: displayName,
            language: language,
            languageName: languageName,
            downloadUrl: downloadUrl,
            fileSizeBytes: fileSizeBytes,
            isDownloaded: isDownloaded
        )
    }
}

extension AyahTafsirDTO {
    func toDomain() -> AyahTafsir {
        AyahTafsir(surah: surah, ayah: ayah, text: text)
    }
}
