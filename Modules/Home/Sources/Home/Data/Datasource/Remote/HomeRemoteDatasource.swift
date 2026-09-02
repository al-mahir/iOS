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
        let firstName = NSLocalizedString("Gust", comment: "")
        let initials = NSLocalizedString("JD", comment: "")
        return Just(UserGreetingEntity(firstName: firstName, initials: initials))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func fetchActiveCirclesMock() -> AnyPublisher<[ActiveCircleEntity], Error> {
        let circles = [
            ActiveCircleEntity(
                title: NSLocalizedString("Al-Baqarah Revision", comment: ""),
                host: NSLocalizedString("Omar Al-Fadl", comment: "")
            ),
            ActiveCircleEntity(
                title: NSLocalizedString("Beginners Children", comment: ""),
                host: NSLocalizedString("Hassan Khalil", comment: "")
            )
        ]
        return Just(circles).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func fetchLastReadMock() -> AnyPublisher<LastReadEntity, Error> {
        let surahName = NSLocalizedString("Al-Kahf", comment: "")
        return Just(LastReadEntity(surahName: surahName, ayahNumber: 45, juzNumber: 15, pageNumber: 293, progress: 0.75))
            .setFailureType(to: Error.self).eraseToAnyPublisher()
    }

}
