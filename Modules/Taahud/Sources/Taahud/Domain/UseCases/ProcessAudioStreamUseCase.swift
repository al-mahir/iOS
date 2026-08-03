//
//  ProcessAudioStreamUseCase.swift
//  Reading
//

import Foundation

public protocol ProcessAudioStreamUseCaseProtocol {
    /// Starts microphone capture and forwards every converted PCM16 frame to
    /// the recitation engine until `stop()` is called or the audio stream
    /// throws. Returns immediately; work continues on a background Task.
    func start(onError: @escaping (Error) -> Void) async throws
    func stop() async
}

/// Wires the microphone (`AudioSessionRepository`) to the live socket
/// (`RecitationRepository`): every frame captured is streamed as a binary
/// WebSocket frame with no buffering beyond what the OS/audio tap already does.
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
