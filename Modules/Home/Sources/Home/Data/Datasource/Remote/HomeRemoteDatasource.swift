//
//  HomeRemoteDatasource.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine
import Foundation
import NetworkKit

protocol HomeRemoteDataSourceProtocol {
    func fetchRandomAyah() -> AnyPublisher<QuranComResponseDTO, NetworkError>
    func fetchGreetingMock() -> AnyPublisher<UserGreetingEntity, Error>
    func fetchLastReadMock() -> AnyPublisher<LastReadEntity, Error>
    func fetchActiveCirclesMock() -> AnyPublisher<[ActiveCircleEntity], Error>
}

final class HomeRemoteDataSource: HomeRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchRandomAyah() -> AnyPublisher<QuranComResponseDTO, NetworkError> {
            return networkService.requestExternal(HomeEndpoint.randomAyah)
        }

    func fetchGreetingMock() -> AnyPublisher<UserGreetingEntity, Error> {
        Just(UserGreetingEntity(firstName: "Ahmed", initials: "JD"))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func fetchLastReadMock() -> AnyPublisher<LastReadEntity, Error> {
        Just(LastReadEntity(surahName: "Al-Kahf", ayahNumber: 45, juzNumber: 15, pageNumber: 293, progress: 0.75))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func fetchActiveCirclesMock() -> AnyPublisher<[ActiveCircleEntity], Error> {
        let circles = [
            ActiveCircleEntity(title: "Al-Baqarah Revision", host: "Omar Al-Fadl"),
            ActiveCircleEntity(title: "Beginners Children", host: "Hassan Khalil")
        ]
        return Just(circles).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
