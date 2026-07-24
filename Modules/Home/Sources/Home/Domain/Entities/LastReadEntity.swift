//
//  LastReadEntity.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Foundation
public struct LastReadEntity {
    public let surahName: String
    public let ayahNumber: Int
    public let juzNumber: Int
    public let pageNumber: Int
    public let progress: Double

    public init(surahName: String, ayahNumber: Int, juzNumber: Int, pageNumber: Int, progress: Double) {
        self.surahName = surahName
        self.ayahNumber = ayahNumber
        self.juzNumber = juzNumber
        self.pageNumber = pageNumber
        self.progress = progress
    }
}
