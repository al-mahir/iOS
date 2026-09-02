//
//  UpdateCircleUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class UpdateCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circle: CircleModel, params: UpdateCircleParams)
        -> AnyPublisher<CircleModel, CircleError>
    {
        guard circle.canUpdate else {
            return Fail(
                error: CircleError.invalidStateTransition(
                    current: circle.status,
                    attempted: "update"
                )
            ).eraseToAnyPublisher()
        }
        return repository.updateCircle(circleId: circle.id, params: params)
    }
}
