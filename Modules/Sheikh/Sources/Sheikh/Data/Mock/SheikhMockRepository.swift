//
//  SheikhMockRepository.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import Combine
import NetworkKit

final class SheikhMockRepository: SheikhRepositoryProtocol {

    private let simulatedDelay: TimeInterval

    init(simulatedDelay: TimeInterval = 0.8) {
        self.simulatedDelay = simulatedDelay
    }

    // MARK: - SheikhRepositoryProtocol

    func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError> {
        Just(SheikhMockData.all)
            .delay(for: .seconds(simulatedDelay), scheduler: DispatchQueue.main)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError> {
        if let sheikh = SheikhMockData.all.first(where: { $0.id == id }) {
            return Just(sheikh)
                .delay(for: .seconds(simulatedDelay), scheduler: DispatchQueue.main)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.notFound(message: "Sheikh not found in mock data"))
                .eraseToAnyPublisher()
        }
    }

    func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError> {
        let query = name?.lowercased() ?? ""

        let filtered = SheikhMockData.all
            .filter { query.isEmpty || $0.fullName.lowercased().contains(query) }
            .map { sheikh in
                SheikhSearchResult(
                    id: sheikh.id,
                    username: sheikh.username,
                    firstName: sheikh.firstName,
                    lastName: sheikh.lastName,
                    email: sheikh.email,
                    profilePictureUrl: sheikh.profilePictureUrl,
                    sheikhStatus: sheikh.sheikhStatus,
                    rate: sheikh.rate,
                    startIndex: nil,
                    endIndex: nil
                )
            }

        return Just(filtered)
            .delay(for: .seconds(simulatedDelay * 0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
