//
//  HandleTokenRenewalUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public protocol HandleTokenRenewalUseCaseProtocol: Sendable {
    func execute(circleId: String) async throws -> String
}

public final class HandleTokenRenewalUseCase: HandleTokenRenewalUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circleId: String) async throws -> String {
        try await repository.renewToken(circleId: circleId)
    }
}
