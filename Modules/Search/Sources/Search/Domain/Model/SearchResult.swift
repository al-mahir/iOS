//
//  SearchResult.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//

import Foundation

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let surah: Surah
    let ayah: Ayah
    let matchedText: String
    let relevanceScore: Double
    let pageNumber: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
}
