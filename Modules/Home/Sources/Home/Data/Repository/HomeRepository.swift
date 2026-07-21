//
//  HomeRepository.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine
import Foundation
import NetworkKit

public final class HomeRepository: HomeRepositoryProtocol {
    private let remoteDataSource: HomeRemoteDataSourceProtocol
    private let localDataSource: HomeLocalDataSourceProtocol

    init(remoteDataSource: HomeRemoteDataSourceProtocol, localDataSource: HomeLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func fetchGreeting() -> AnyPublisher<UserGreetingEntity, Error> { remoteDataSource.fetchGreetingMock() }
    public func fetchLastRead() -> AnyPublisher<LastReadEntity, Error> { remoteDataSource.fetchLastReadMock() }
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
