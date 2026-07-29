//
//  GetSheikhDetailUseCase.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public protocol GetSheikhDetailUseCaseProtocol: Sendable {
    func execute(id: String) -> AnyPublisher<Sheikh, NetworkError>
}

public final class GetSheikhDetailUseCase: GetSheikhDetailUseCaseProtocol {
    private let repository: any SheikhRepositoryProtocol

    public init(repository: any SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String) -> AnyPublisher<Sheikh, NetworkError> {
        repository.getSheikhByID(id)
    }
}
