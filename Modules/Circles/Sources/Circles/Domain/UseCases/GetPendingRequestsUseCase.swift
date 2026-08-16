//
//  GetPendingRequestsUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class GetPendingRequestsUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        circleId: String,
        page: CirclePageRequest = CirclePageRequest()
    ) -> AnyPublisher<CirclePage<PendingJoinRequest>, CircleError> {
        repository.getPendingRequests(circleId: circleId, page: page)
    }
}
