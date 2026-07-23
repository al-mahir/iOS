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

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    
    public func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError> {
        networkService.request(SheikhEndpoints.getAllSheikhs)
    }

    public func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError> {
        networkService.request(SheikhEndpoints.getSheikhByID(id: id))
    }

    public func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError> {
        networkService.requestExternal(SheikhEndpoints.searchSheikhs(name: name))
    }
}
