//
//  QuranRepositoryProtocol.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation
import Combine

@preconcurrency protocol QuranRepositoryProtocol {
    // MARK: - Core Data Fetching
    func fetchAllSurahs() -> AnyPublisher<[Surah], Error>
    func fetchAllJuz() -> AnyPublisher<[Juz], Error>
    
    // MARK: - Search History
    func fetchSearchHistory() -> AnyPublisher<[SearchHistoryItem], Error>
    func saveSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error>
    func clearSearchHistory(for category: SearchCategory) -> AnyPublisher<Void, Error>
    func deleteSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error> 
}
