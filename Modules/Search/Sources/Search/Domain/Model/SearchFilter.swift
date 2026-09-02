//
//  SearchFilter.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//


struct SearchFilter {
    var surahIds: Set<Int> = []
    var juzNumbers: Set<Int> = []
    var tafsirType: TafsirType = .summary
    
    var hasActiveFilters: Bool {
        !surahIds.isEmpty || !juzNumbers.isEmpty
    }
}

enum TafsirType: String, CaseIterable, Codable {
    case summary = "Summary Tafsir"
    case detailed = "Detailed Commentary"
    case classical = "Classical Sources"
}
