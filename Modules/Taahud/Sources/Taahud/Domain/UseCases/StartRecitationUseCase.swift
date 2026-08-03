//
//  StartRecitationUseCase.swift
//  Reading
//

import Foundation

public protocol StartRecitationUseCaseProtocol {
    func execute(config: RecitationStartConfig) async throws -> RecitationSession
}

/// Opens the WebSocket handshake for a new recitation session. Thin by
/// design — the interesting protocol logic lives in the repository
/// implementation — but kept as its own use case so the ViewModel depends
/// only on intent-shaped calls, not repository internals.
public final class StartRecitationUseCase: StartRecitationUseCaseProtocol {
    private let recitationRepository: RecitationRepository

    public init(recitationRepository: RecitationRepository) {
        self.recitationRepository = recitationRepository
    }

    public func execute(config: RecitationStartConfig) async throws -> RecitationSession {
        try await recitationRepository.startSession(config: config)
    }
}
