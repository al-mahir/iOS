// Models/SearchModels.swift
import Foundation

// MARK: - Search Category
enum SearchCategory: String, CaseIterable, Identifiable, Codable {
    case surah = "Surah"
    case juz = "Juz'"
    case ayah = "Ayah"
    case semantic = "Semantic"
    
    var id: String { self.rawValue }
}

// MARK: - Quran Models
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

struct Juz: Identifiable, Codable, Hashable {
    let id: Int
    let number: Int
    let surahRange: String
    let ayahRange: String
    let pageStart: Int
    let pageEnd: Int
}

struct Ayah: Identifiable, Codable, Hashable {
    let id: String
    let surahId: Int
    let number: Int
    let arabicText: String
    let englishTranslation: String
    let tafsir: String?
    let pageNumber: Int
}

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

// MARK: - Search History
struct SearchHistoryItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let query: String
    let timestamp: TimeInterval
    let category: SearchCategory
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    init(query: String, category: SearchCategory) {
        self.query = query
        self.timestamp = Date().timeIntervalSince1970
        self.category = category
    }
    
    init(query: String, timestamp: TimeInterval, category: SearchCategory) {
        self.query = query
        self.timestamp = timestamp
        self.category = category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(query)
        hasher.combine(category)
    }
    
    static func == (lhs: SearchHistoryItem, rhs: SearchHistoryItem) -> Bool {
        lhs.query == rhs.query && lhs.category == rhs.category
    }
}
