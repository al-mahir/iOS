//
//  AyahCacheDTO.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Foundation

struct AyahCachedModel: Codable {
    let arabicText: String
    let translation: String
    let surahName: String
    let ayahNumber: Int
    let juzNumber: Int
    let pageNumber: Int
    let timestamp: Date
}
