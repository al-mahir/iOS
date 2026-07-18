//
//  MockQuranRepository.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//
// Repositories/MockQuranRepository.swift
import Foundation
import Combine

class MockQuranRepository: QuranRepositoryProtocol {
    private let mockDataService = MockDataService.shared
    private let userDefaults = UserDefaults.standard
    private let historyKey = "searchHistory"
    
    func fetchAllSurahs() -> AnyPublisher<[Surah], Error> {
        return Just(mockDataService.getAllSurahs())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchAllJuz() -> AnyPublisher<[Juz], Error> {
        return Just(mockDataService.getAllJuz())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchAyahs(for surahId: Int) -> AnyPublisher<[Ayah], Error> {
        return Just(mockDataService.getAyahsForSurah(surahId))
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchAyahsj(forj juzNumber: Int) -> AnyPublisher<[Ayah], Error> {
        return Just(mockDataService.getAyahsForJuz(juzNumber))
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func search(query: String, category: SearchCategory, filters: SearchFilter) -> AnyPublisher<[SearchResult], Error> {
        return Just(mockDataService.performSearch(query: query, category: category, filters: filters))
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchSearchHistory() -> AnyPublisher<[SearchHistoryItem], Error> {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        do {
            let history = try JSONDecoder().decode([SearchHistoryItem].self, from: data)
            return Just(history)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func saveSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error> {
        return fetchSearchHistory()
            .flatMap { history -> AnyPublisher<Void, Error> in
                var updatedHistory = history
                updatedHistory.removeAll { $0.query.lowercased() == item.query.lowercased() && $0.category == item.category }
                // Insert new item at the beginning
                updatedHistory.insert(item, at: 0)
                // Keep only last 20 items
                if updatedHistory.count > 20 {
                    updatedHistory = Array(updatedHistory.prefix(20))
                }
                
                do {
                    let data = try JSONEncoder().encode(updatedHistory)
                    self.userDefaults.set(data, forKey: self.historyKey)
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error> {
        return fetchSearchHistory()
            .flatMap { history -> AnyPublisher<Void, Error> in
                var updatedHistory = history
                updatedHistory.removeAll { $0.id == item.id }
                
                do {
                    let data = try JSONEncoder().encode(updatedHistory)
                    self.userDefaults.set(data, forKey: self.historyKey)
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func clearSearchHistory() -> AnyPublisher<Void, Error> {
        userDefaults.removeObject(forKey: historyKey)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
