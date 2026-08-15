//
//  ProcessAudioStreamUseCase.swift
//  Taahud
//

import Foundation

public protocol ProcessAudioStreamUseCaseProtocol {
    
    func start(onError: @escaping (Error) -> Void) async throws
    func stop() async
}

public final class ProcessAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol {
    private let audioSessionRepository: AudioSessionRepository
    private let recitationRepository: RecitationRepository
    private var streamingTask: Task<Void, Never>?

    public init(audioSessionRepository: AudioSessionRepository, recitationRepository: RecitationRepository) {
        self.audioSessionRepository = audioSessionRepository
        self.recitationRepository = recitationRepository
    }

    public func start(onError: @escaping (Error) -> Void) async throws {
        // Cancel any previous run before starting a fresh one.
        streamingTask?.cancel()

        let frames = try await audioSessionRepository.startCapture()

        streamingTask = Task { [recitationRepository] in
            do {
                for try await frame in frames {
                    try Task.checkCancellation()
                    try await recitationRepository.sendAudioFrame(frame)
                }
            } catch is CancellationError {
                // Expected on stop(); not an error condition.
            } catch {
                onError(error)
            }
        }
    }

    public func stop() async {
        streamingTask?.cancel()
        streamingTask = nil
        await audioSessionRepository.stopCapture()
    }
}
