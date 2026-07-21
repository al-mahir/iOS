//
//  GetActiveCirclesUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Combine
public protocol GetActiveCirclesUseCaseProtocol { func execute() -> AnyPublisher<[ActiveCircleEntity], Error> }
public final class GetActiveCirclesUseCase: GetActiveCirclesUseCaseProtocol {
    private let repo: HomeRepositoryProtocol
    public init(repo: HomeRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<[ActiveCircleEntity], Error> { repo.fetchActiveCircles() }
}
