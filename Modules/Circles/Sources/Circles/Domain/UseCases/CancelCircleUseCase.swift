//
//  CancelCircleUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class CancelCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circle: CircleModel) -> AnyPublisher<Void, CircleError>
    {
        guard circle.canCancel else {
            return Fail(
                error: CircleError.invalidStateTransition(
                    current: circle.status,
                    attempted: "cancel"
                )
            ).eraseToAnyPublisher()
        }
        return repository.cancelCircle(circleId: circle.id)
    }
}
