//
//  JoinLiveSessionUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public protocol JoinLiveSessionUseCaseProtocol: Sendable {
    func execute(circleId: String, channelName: String, agoraToken: String, uid: Int) async throws
}

public final class JoinLiveSessionUseCase: JoinLiveSessionUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(circleId: String, channelName: String, agoraToken: String, uid: Int) async throws {
        try await repository.joinSession(
            circleId: circleId,
            channelName: channelName,
            agoraToken: agoraToken,
            uid: uid
        )
    }
}
