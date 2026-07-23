//
//  SheikhRepositoryProtocol.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import Combine
import NetworkKit

public protocol SheikhRepositoryProtocol {

    func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError>

    func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError>

    func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError>
}
