//
//  GetFreshAgoraTokenUseCase.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 08/08/2026.
//

import Foundation

public protocol GetFreshAgoraTokenUseCaseProtocol: Sendable {
    func execute(requestId: String) async throws -> (token: String, channelName: String, userAccount: String?)
}

public final class GetFreshAgoraTokenUseCase: GetFreshAgoraTokenUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(requestId: String) async throws -> (token: String, channelName: String, userAccount: String?) {
        try await repository.getFreshAgoraToken(requestId: requestId)
    }
}
