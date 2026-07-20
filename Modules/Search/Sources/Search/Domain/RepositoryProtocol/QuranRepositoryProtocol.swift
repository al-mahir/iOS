//
//  QuranRepositoryProtocol.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation
import Combine

protocol QuranRepositoryProtocol {
    // MARK: - Core Data Fetching
    func fetchAllSurahs() -> AnyPublisher<[Surah], Error>
    func fetchAllJuz() -> AnyPublisher<[Juz], Error>
    func fetchAyahs(for surahId: Int) -> AnyPublisher<[Ayah], Error>
    func fetchAyahsj(forj juzNumber: Int) -> AnyPublisher<[Ayah], Error>
    
    // MARK: - Search
    func search(query: String, category: SearchCategory, filters: SearchFilter) -> AnyPublisher<[SearchResult], Error>
    
    // MARK: - Search History
    func fetchSearchHistory() -> AnyPublisher<[SearchHistoryItem], Error>
    func saveSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error>
    func clearSearchHistory(for category: SearchCategory) -> AnyPublisher<Void, Error>
    func deleteSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error> 
}
