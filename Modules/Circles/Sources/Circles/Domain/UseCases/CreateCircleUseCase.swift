//
//  CreateCircleUseCase.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public final class CreateCircleUseCase {

    private let repository: any CircleRepositoryProtocol

    public init(repository: any CircleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ params: CreateCircleParams) -> AnyPublisher<
        CircleModel, CircleError
    > {
        repository.createCircle(params)
    }
}
