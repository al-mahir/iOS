//
//  ApproveJoinRequestUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//
import Foundation
import Combine

public final class ApproveJoinRequestUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        circleId: String,
        userId: String
    ) -> AnyPublisher<CircleMember, CircleError> {
        repository.approveJoinRequest(circleId: circleId, userId: userId)
    }
}
