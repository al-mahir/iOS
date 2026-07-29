//
//  SheikhRepositoryImpl.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public final class SheikhRepositoryImpl: SheikhRepositoryProtocol, @unchecked Sendable {

    private let networkService: any NetworkServiceProtocol
    private var favoriteIDs: Set<String> = ["00000000-0000-0000-0000-000000000000", "44444444-4444-4444-4444-444444444444"]

    public init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    public func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError> {
        networkService.request(SheikhEndpoints.getAllSheikhs)
            .map { [weak self] (sheikhs: [Sheikh]) in
                self?.applyFavorites(to: sheikhs) ?? sheikhs
            }
            .catch { _ in
                Just(self.mockSheikhs())
                    .setFailureType(to: NetworkError.self)
            }
            .eraseToAnyPublisher()
    }

    public func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError> {
        networkService.request(SheikhEndpoints.getSheikhByID(id: id))
            .map { [weak self] (sheikh: Sheikh) in
                var updated = sheikh
                if let self = self {
                    updated.isFavorite = self.favoriteIDs.contains(sheikh.id)
                }
                return updated
            }
            .catch { [weak self] _ -> AnyPublisher<Sheikh, NetworkError> in
                let allMocks = self?.mockSheikhs() ?? SheikhMockData.all
                let target = allMocks.first(where: { $0.id == id }) ?? SheikhMockData.first
                return Just(target)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError> {
        networkService.requestExternal(SheikhEndpoints.searchSheikhs(name: name))
            .catch { [weak self] _ -> AnyPublisher<[SheikhSearchResult], NetworkError> in
                let query = name?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let all = self?.mockSheikhs() ?? SheikhMockData.all
                let filtered = query.isEmpty ? all : all.filter { $0.fullName.lowercased().contains(query) }
                let results = filtered.map { sheikh in
                    SheikhSearchResult(
                        id: sheikh.id,
                        username: sheikh.username,
                        firstName: sheikh.firstName,
                        lastName: sheikh.lastName,
                        email: sheikh.email,
                        profilePictureUrl: sheikh.profilePictureUrl,
                        sheikhStatus: sheikh.sheikhStatus,
                        rate: sheikh.rate
                    )
                }
                return Just(results)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func toggleFavorite(sheikhID: String) -> AnyPublisher<Bool, NetworkError> {
        if favoriteIDs.contains(sheikhID) {
            favoriteIDs.remove(sheikhID)
        } else {
            favoriteIDs.insert(sheikhID)
        }
        let isFav = favoriteIDs.contains(sheikhID)
        return Just(isFav)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    private func mockSheikhs() -> [Sheikh] {
        applyFavorites(to: SheikhMockData.all)
    }

    private func applyFavorites(to sheikhs: [Sheikh]) -> [Sheikh] {
        sheikhs.map { s in
            var copy = s
            copy.isFavorite = favoriteIDs.contains(s.id)
            return copy
        }
    }
}
