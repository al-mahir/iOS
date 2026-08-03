//
//  ToggleFavoriteSheikhUseCase.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public protocol ToggleFavoriteSheikhUseCaseProtocol: Sendable {
    func execute(id: String) -> AnyPublisher<Bool, NetworkError>
}

public final class ToggleFavoriteSheikhUseCase: ToggleFavoriteSheikhUseCaseProtocol {
    private let repository: any SheikhRepositoryProtocol

    public init(repository: any SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String) -> AnyPublisher<Bool, NetworkError> {
        repository.toggleFavorite(sheikhID: id)
    }
}
