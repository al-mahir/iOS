//
//  HomeLocalDatasource.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Foundation

protocol HomeLocalDataSourceProtocol {
    func getCachedAyah() -> AyahOfTheDayEntity?
    func saveAyah(_ ayah: AyahOfTheDayEntity)
    func isCacheValid() -> Bool
}

final class HomeLocalDataSource: HomeLocalDataSourceProtocol {
    private let defaults = UserDefaults.standard
    private let cacheKey = "cached_ayah_of_the_day"

    func getCachedAyah() -> AyahOfTheDayEntity? {
        guard let data = defaults.data(forKey: cacheKey),
              let dto = try? JSONDecoder().decode(AyahCachedModel.self, from: data) else {
            return nil
        }
        return dto.toEntity()
    }

    func saveAyah(_ ayah: AyahOfTheDayEntity) {
        let dto = ayah.toCacheDTO()
        
        if let data = try? JSONEncoder().encode(dto) {
            defaults.set(data, forKey: cacheKey)
        }
    }

    func isCacheValid() -> Bool {
        guard let data = defaults.data(forKey: cacheKey),
              let dto = try? JSONDecoder().decode(AyahCachedModel.self, from: data) else {
            return false
        }
        return Calendar.current.isDateInToday(dto.timestamp)
    }
}
