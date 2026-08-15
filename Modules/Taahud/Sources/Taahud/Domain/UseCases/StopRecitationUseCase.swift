//
//  StopRecitationUseCase.swift
//  Reading
//

import Foundation

public protocol StopRecitationUseCaseProtocol {
    func execute() async
}

public final class StopRecitationUseCase: StopRecitationUseCaseProtocol {
    private let processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol
    private let recitationRepository: RecitationRepository

    public init(processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol, recitationRepository: RecitationRepository) {
        self.processAudioStreamUseCase = processAudioStreamUseCase
        self.recitationRepository = recitationRepository
    }

    public func execute() async {
        await processAudioStreamUseCase.stop()
        do {
            try await recitationRepository.stopSession()
        } catch {
            print("⚠️ [StopRecitationUseCase] teardown error (non-fatal): \(error.localizedDescription)")
        }
    }
}
