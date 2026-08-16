//
//  StartCircleUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class StartCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circle: CircleModel) -> AnyPublisher<Void, CircleError>
    {
        guard circle.canStart else {
            return Fail(
                error: CircleError.invalidStateTransition(
                    current: circle.status,
                    attempted: "start"
                )
            ).eraseToAnyPublisher()
        }
        return repository.startCircle(circleId: circle.id)
    }
}
