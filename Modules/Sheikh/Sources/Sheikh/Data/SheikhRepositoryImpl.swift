//
//  SheikhRepositoryImpl.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import Combine
import NetworkKit

public final class SheikhRepositoryImpl: SheikhRepositoryProtocol {

    // MARK: - Dependencies

    private let networkService: any NetworkServiceProtocol

    // MARK: - Init

    init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    // MARK: - SheikhRepositoryProtocol

    public func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError> {
        networkService.request(SheikhEndpoints.getAllSheikhs)
    }

    public func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError> {
        networkService.request(SheikhEndpoints.getSheikhByID(id: id))
    }

    /// The search endpoint returns a raw JSON array (no `APISuccessResponse` envelope),
    /// so we use `requestExternal` which decodes `T` directly from the root of the response.
    public func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError> {
        networkService.requestExternal(SheikhEndpoints.searchSheikhs(name: name))
    }
}
