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
    

    
    func fetchSearchHistory() -> AnyPublisher<[SearchHistoryItem], Error> {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        do {
            let history = try JSONDecoder().decode([SearchHistoryItem].self, from: data)
            let sortedHistory = history.sorted(by: { $0.timestamp > $1.timestamp })
            return Just(sortedHistory).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func saveSearchHistory(item: SearchHistoryItem) -> AnyPublisher<Void, Error> {
        return fetchSearchHistory()
            .flatMap { history -> AnyPublisher<Void, Error> in
                var updatedHistory = history
                updatedHistory.removeAll { $0.id == item.id }
                
                updatedHistory.insert(item, at: 0)
                
                if updatedHistory.count > 50 {
                    updatedHistory = Array(updatedHistory.prefix(50))
                }
                
                do {
                    let data = try JSONEncoder().encode(updatedHistory)
                    self.userDefaults.set(data, forKey: self.historyKey)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
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
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func clearSearchHistory(for category: SearchCategory) -> AnyPublisher<Void, Error> {
        return fetchSearchHistory()
            .flatMap { history -> AnyPublisher<Void, Error> in
                var updatedHistory = history
                updatedHistory.removeAll { $0.category == category }
                
                do {
                    let data = try JSONEncoder().encode(updatedHistory)
                    self.userDefaults.set(data, forKey: self.historyKey)
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                } catch {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
