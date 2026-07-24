//
//  TafsirMapper.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//

extension TafsirDTO{
    func toEntity() -> TafsirData {
        TafsirData(
            surah: surah,
            ayah: ayah,
            text: text
        )
    }
}
