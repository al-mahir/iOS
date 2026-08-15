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
    private let passwordGenerator: () -> String

    public init(
        repository: any CircleRepositoryProtocol,
        passwordGenerator: @escaping () -> String = PrivateCirclePasswordGenerator.generate
    ) {
        self.repository = repository
        self.passwordGenerator = passwordGenerator
    }

    public func execute(_ params: CreateCircleParams) -> AnyPublisher<
        CircleModel, CircleError
    > {
        repository.createCircle(params, password: passwordGenerator())
    }
}

public enum PrivateCirclePasswordGenerator {
    public static func generate() -> String {
        String(Int.random(in: 100_000...999_999))
    }
}
