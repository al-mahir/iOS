//
//  GetSheikhsUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Combine
public protocol GetSheikhsUseCaseProtocol { func execute() -> AnyPublisher<[SheikhEntity], Error> }
public final class GetSheikhsUseCase: GetSheikhsUseCaseProtocol {
    private let repo: HomeRepositoryProtocol
    public init(repo: HomeRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<[SheikhEntity], Error> { repo.fetchSheikhs() }
}
