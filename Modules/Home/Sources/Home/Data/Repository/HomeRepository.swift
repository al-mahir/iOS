//
//  HomeRepository.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine
import Foundation
import NetworkKit
import Common

public final class HomeRepository: HomeRepositoryProtocol {
    private let remoteDataSource: HomeRemoteDataSourceProtocol
    private let localDataSource: HomeLocalDataSourceProtocol

    init(remoteDataSource: HomeRemoteDataSourceProtocol, localDataSource: HomeLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func fetchGreeting() -> AnyPublisher<UserGreetingEntity, Error> { remoteDataSource.fetchGreetingMock() }

    public func fetchLastRead() -> AnyPublisher<LastReadEntity?, Error> {
        let entity: LastReadEntity?
        if let progress = ReadingProgressStore.shared.load() {
            entity = LastReadEntity(
                surahName: progress.surahName,
                ayahNumber: progress.ayahNumber,
                juzNumber: progress.juzNumber,
                pageNumber: progress.pageNumber,
                progress: progress.progress
            )
        } else {
            entity = nil
        }
        return Just(entity).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    public func fetchSheikhs() -> AnyPublisher<[SheikhEntity], Error> { remoteDataSource.fetchSheikhsMock() }
    public func fetchActiveCircles() -> AnyPublisher<[ActiveCircleEntity], Error> { remoteDataSource.fetchActiveCirclesMock() }

    public func fetchAyahOfTheDay() -> AnyPublisher<AyahOfTheDayEntity, Error> {
        if localDataSource.isCacheValid(), let cachedAyah = localDataSource.getCachedAyah() {
            return Just(cachedAyah).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return remoteDataSource.fetchRandomAyah()
            .map { dto in
             
                let entity = dto.toEntity()
                self.localDataSource.saveAyah(entity)
                return entity
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
