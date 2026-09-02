//
//  Ayah.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//


struct Ayah: Identifiable, Codable, Hashable {
    let id: String
    let surahId: Int
    let number: Int
    let arabicText: String
    let englishTranslation: String
    let tafsir: String?
    let pageNumber: Int
}