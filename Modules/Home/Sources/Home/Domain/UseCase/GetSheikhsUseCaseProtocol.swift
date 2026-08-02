//
//  GetSheikhsUseCaseProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Combine
import Sheikh
import NetworkKit

public protocol GetSheikhsUseCaseProtocol {
    func execute() -> AnyPublisher<[Sheikh], NetworkError>
}

public final class GetSheikhsUseCase: GetSheikhsUseCaseProtocol {
    private let repo: any SheikhRepositoryProtocol
    public init(repo: any SheikhRepositoryProtocol) { self.repo = repo }
    public func execute() -> AnyPublisher<[Sheikh], NetworkError> { repo.getAllSheikhs() }
}
