//
//  StopRecitationUseCase.swift
//  Reading
//

import Foundation

public protocol StopRecitationUseCaseProtocol {
    func execute() async
}

/// Tears down a session cleanly: stop streaming audio first (so no frames
/// race the `end`/`done` handshake), then send `end` and await `done`.
/// Errors during teardown are logged, never thrown — the user tapped "stop",
/// so the UI should always end up idle regardless of what the socket does.
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
