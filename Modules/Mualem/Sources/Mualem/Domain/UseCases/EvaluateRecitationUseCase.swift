//
//  EvaluateRecitationUseCase.swift
//  Mualem
//

import Foundation

public final class EvaluateRecitationUseCase {
    private let evaluator: VoiceEvaluationServiceProtocol
    
    public init(evaluator: VoiceEvaluationServiceProtocol) {
        self.evaluator = evaluator
    }
    
    /// Starts a recitation evaluation session.
    /// - Parameters:
    ///   - surah: The surah number.
    ///   - ayah: The ayah number.
    ///   - expectedWords: Normalized Arabic words the user is expected to recite.
    ///   - maxDuration: Maximum listening time before auto-completing.
    public func execute(surah: Int, ayah: Int, expectedWords: [String], maxDuration: TimeInterval) -> AsyncStream<RecitationEvent> {
        return evaluator.evaluateStream(
            surah: surah,
            ayah: ayah,
            expectedWords: expectedWords,
            maxDuration: maxDuration
        )
    }
}
