//
//  GetAgoraTokenUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class GetAgoraTokenUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circle: CircleModel) -> AnyPublisher<
        AgoraToken, CircleError
    > {
        guard circle.canRequestToken else {
            return Fail(
                error: CircleError.invalidStateTransition(
                    current: circle.status,
                    attempted: "request Agora token for"
                )
            ).eraseToAnyPublisher()
        }
        return repository.getAgoraToken(circleId: circle.id)
    }
}
