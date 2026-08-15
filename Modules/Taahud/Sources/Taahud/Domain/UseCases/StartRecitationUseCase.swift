//
//  StartRecitationUseCase.swift
//  Taahud
//

import Foundation

public protocol StartRecitationUseCaseProtocol {
    func execute(config: RecitationStartConfig) async throws -> RecitationSession
}

public final class StartRecitationUseCase: StartRecitationUseCaseProtocol {
    private let recitationRepository: RecitationRepository

    public init(recitationRepository: RecitationRepository) {
        self.recitationRepository = recitationRepository
    }

    public func execute(config: RecitationStartConfig) async throws -> RecitationSession {
        try await recitationRepository.startSession(config: config)
    }
}
