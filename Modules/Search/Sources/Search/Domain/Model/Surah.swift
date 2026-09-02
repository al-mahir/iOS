//
//  Surah.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//


struct Surah: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let arabicName: String
    let englishName: String
    let ayahCount: Int
    let revelationType: RevelationType
    let juzStart: Int
    let juzEnd: Int
    let pageStart: Int
    let pageEnd: Int
    
    enum RevelationType: String, Codable {
        case meccan = "Meccan"
        case medinan = "Medinan"
    }
}