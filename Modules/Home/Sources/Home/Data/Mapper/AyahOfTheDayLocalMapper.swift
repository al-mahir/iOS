//
//  AyahOfTheDayLocalMapper.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Foundation

import Foundation

extension AyahCachedModel {
    func toEntity() -> AyahOfTheDayEntity {
        return AyahOfTheDayEntity(
            arabicText: self.arabicText,
            translation: self.translation,
            surahName: self.surahName,
            ayahNumber: self.ayahNumber,
            juzNumber: self.juzNumber,
            pageNumber: self.pageNumber
        )
    }
}


extension AyahOfTheDayEntity {
    func toCacheDTO() -> AyahCachedModel {
        return AyahCachedModel(
            arabicText: self.arabicText,
            translation: self.translation,
            surahName: self.surahName,
            ayahNumber: self.ayahNumber,
            juzNumber: self.juzNumber,
            pageNumber: self.pageNumber,
            timestamp: Date()
        )
    }
}
