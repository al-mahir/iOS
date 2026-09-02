//
//  LeaveLiveSessionUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public protocol LeaveLiveSessionUseCaseProtocol: Sendable {
    func execute(circleId: String) async throws
}

public final class LeaveLiveSessionUseCase: LeaveLiveSessionUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circleId: String) async throws {
        try await repository.leaveSession(circleId: circleId)
    }
}
