//
//  PageLineRowMapper.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import Foundation

extension PageLineRow {
    func toDomainEntity(words: [QuranWord]) -> MushafLine {
        let lineType = MushafLineType(rawValue: self.lineType) ?? .ayah

        return MushafLine(
            id: self.lineNumber,
            lineType: lineType,
            isCentered: self.isCentered,
            surahNumber: self.surahNumber,
            words: lineType == .ayah ? words : []
        )
    }
}
