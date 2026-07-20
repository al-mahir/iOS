//
//  MushafSearchLocalDataSource.swift
//  Mushaf
//

import Foundation

protocol MushafSearchLocalDataSource {
    func searchAyahs(query: String) throws -> [SearchResult]
}

final class MushafSearchLocalDataSourceImpl: MushafSearchLocalDataSource {
    private let searchDAO: SearchDAO
    private let pagesDAO: PagesDAO

    init(searchDAO: SearchDAO, pagesDAO: PagesDAO) {
        self.searchDAO = searchDAO
        self.pagesDAO = pagesDAO
    }

    func searchAyahs(query: String) throws -> [SearchResult] {
        let normalizedQuery = query.normalizedArabic()
        guard !normalizedQuery.isEmpty else { return [] }

        // 1. Fetch matching words
        let matches = try searchDAO.searchWords(normalizedQuery: normalizedQuery)

        // 2. Group matches by Ayah reference (Surah, Ayah) to preserve uniqueness
        var seen = Set<String>()
        var ayahRefs: [(surah: Int, ayah: Int)] = []
        for match in matches {
            let key = "\(match.surah):\(match.ayah)"
            if seen.insert(key).inserted {
                ayahRefs.append((match.surah, match.ayah))
            }
        }

        var results: [SearchResult] = []

        for ref in ayahRefs {
            let words = try searchDAO.wordsForAyah(surah: ref.surah, ayah: ref.ayah)
            guard let firstWord = words.first else { continue }

            let fullAyahText = words.map(\.textDisplay).joined(separator: " ")
            let fullAyahNormalized = words.map(\.textNormalized).joined(separator: " ")
            
            let page = try pagesDAO.pageNumber(forWordId: firstWord.id) ?? 0

            let surahModel = MockDataService.shared.surah(for: ref.surah)

            let ayahModel = Ayah(
                id: "\(ref.surah):\(ref.ayah)",
                surahId: ref.surah,
                number: ref.ayah,
                arabicText: fullAyahText,
                englishTranslation: "",
                tafsir: nil,
                pageNumber: page
            )
            
            let relevanceScore = calculateRelevance(
                query: normalizedQuery,
                ayahNormalized: fullAyahNormalized
            )

            results.append(
                SearchResult(
                    surah: surahModel,
                    ayah: ayahModel,
                    matchedText: query,
                    relevanceScore: relevanceScore,
                    pageNumber: page
                )
            )
        }

        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    private func calculateRelevance(query: String, ayahNormalized: String) -> Double {
        if ayahNormalized == query {
            return 1.0
        } else if ayahNormalized.hasPrefix(query) {
            return 0.8
        } else {
            
            return Double(query.count) / Double(max(ayahNormalized.count, 1))
        }
    }
}
