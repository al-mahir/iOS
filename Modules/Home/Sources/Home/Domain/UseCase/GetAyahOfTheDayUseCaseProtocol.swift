//
//  GetAyahOfTheDayUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Combine
public protocol GetAyahOfTheDayUseCaseProtocol { func execute() -> AnyPublisher<AyahOfTheDayEntity, Error> }
public final class GetAyahOfTheDayUseCase: GetAyahOfTheDayUseCaseProtocol {
    private let repo: HomeRepositoryProtocol
    public init(repo: HomeRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<AyahOfTheDayEntity, Error> { repo.fetchAyahOfTheDay() }
}
