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
    
    public func execute(surah: Int, ayah: Int, waitTime: TimeInterval) -> AsyncStream<RecitationEvent> {
        return evaluator.evaluateStream(surah: surah, ayah: ayah, simulatedDuration: waitTime)
    }
}
