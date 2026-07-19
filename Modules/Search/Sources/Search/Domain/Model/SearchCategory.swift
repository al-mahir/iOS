//
//  Surah.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation

enum SearchCategory: String, CaseIterable, Identifiable, Codable {
    case surah = "Surah"
    case juz = "Juz'"
    case ayah = "Ayah"
    case semantic = "Semantic"
    
    var id: String { self.rawValue }
}









