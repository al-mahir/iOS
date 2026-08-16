//
//  RemoveMemberUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class RemoveMemberUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        circleId: String,
        userId: String
    ) -> AnyPublisher<Void, CircleError> {
        repository.removeMember(circleId: circleId, userId: userId)
    }
}
