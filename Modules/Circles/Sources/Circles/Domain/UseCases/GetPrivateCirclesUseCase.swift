//
//  GetPrivateCirclesUseCase.swift
//  Circles
//

import Combine

public final class GetPrivateCirclesUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        repository.getPrivateCircles()
    }
}
