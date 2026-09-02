//
//  ListCirclesUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class ListCirclesUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        params: ListCirclesParams = ListCirclesParams(),
        page: CirclePageRequest = CirclePageRequest()
    ) -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        repository.listCircles(params: params, page: page)
    }
}
