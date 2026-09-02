//
//  GetSheikhsUseCase.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public protocol GetSheikhsUseCaseProtocol: Sendable {
    func execute() -> AnyPublisher<[Sheikh], NetworkError>
}

public final class GetSheikhsUseCase: GetSheikhsUseCaseProtocol {
    private let repository: any SheikhRepositoryProtocol

    public init(repository: any SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<[Sheikh], NetworkError> {
        repository.getAllSheikhs()
    }
}
