//
//  LeaveCircleUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class LeaveCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circleId: String) -> AnyPublisher<Void, CircleError> {
        repository.leaveCircle(circleId: circleId)
    }
}
