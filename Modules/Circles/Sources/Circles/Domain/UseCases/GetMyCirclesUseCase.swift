//
//  GetMyCirclesUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class GetMyCirclesUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        page: CirclePageRequest = CirclePageRequest()
    ) -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        repository.getMyCircles(page: page)
    }
}
