//
//  GetGreetingUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine

public protocol GetGreetingUseCaseProtocol { func execute() -> AnyPublisher<UserGreetingEntity, Error> }
public final class GetGreetingUseCase: GetGreetingUseCaseProtocol {
    private let repo: HomeRepositoryProtocol
    public init(repo: HomeRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<UserGreetingEntity, Error> { repo.fetchGreeting() }
}






