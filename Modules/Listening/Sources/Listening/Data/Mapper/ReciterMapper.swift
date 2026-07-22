//
//  ReciterMapper.swift
//  Listening
//

import Foundation

enum ReciterMapper {

    static func toDomain(_ dto: ReciterDTO) -> Reciter {
        Reciter(
            id: dto.id,
            name: dto.reciterName,
            arabicName: dto.reciterName, // Quran.com v4 returns transliterated name; keep same for now
            style: dto.style,
            translatedName: dto.translatedName?.name
        )
    }

    static func toDomainList(_ dtos: [ReciterDTO]) -> [Reciter] {
        dtos.map { toDomain($0) }
    }
}
