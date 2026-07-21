//
//  GetLastReadUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Combine
public protocol GetLastReadUseCaseProtocol { func execute() -> AnyPublisher<LastReadEntity, Error> }
public final class GetLastReadUseCase: GetLastReadUseCaseProtocol {
    private let repo: HomeRepositoryProtocol
    public init(repo: HomeRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<LastReadEntity, Error> { repo.fetchLastRead() }
}
