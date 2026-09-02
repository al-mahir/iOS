//
//  JoinPrivateCircleUseCase.swift
//  Circles
//

import Combine

public final class JoinPrivateCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(token: String) -> AnyPublisher<CircleMembership, CircleError> {
        repository.joinPrivateCircle(token: token)
    }
}
