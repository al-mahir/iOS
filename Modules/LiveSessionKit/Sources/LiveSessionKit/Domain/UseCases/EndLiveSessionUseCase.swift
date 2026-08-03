//
//  EndLiveSessionUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//
import Foundation

public protocol EndLiveSessionUseCaseProtocol: Sendable {
    func execute(circleId: String, isHost: Bool) async throws
}

public final class EndLiveSessionUseCase: EndLiveSessionUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circleId: String, isHost: Bool) async throws {
        guard isHost else {
            throw LiveSessionError.notHost
        }
        try await repository.endSession(circleId: circleId, isHost: isHost)
    }
}
