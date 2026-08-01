//
//  SheikhRepositoryProtocol.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public protocol SheikhRepositoryProtocol: Sendable {

    func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError>

    func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError>

    func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError>

    func toggleFavorite(sheikhID: String) -> AnyPublisher<Bool, NetworkError>
}
