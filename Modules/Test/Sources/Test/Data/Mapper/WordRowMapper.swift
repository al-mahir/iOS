//
//  WordRowMapper.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation

extension WordRow {
    func toDomainEntity() -> QuranWord {
        QuranWord(
            id: self.id,
            surah: self.surah,
            ayah: self.ayah,
            wordPosition: self.word,
            text: self.text
        )
    }
}
