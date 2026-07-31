//
//  MockVoiceEvaluationService.swift
//  Mualem
//
//  Simulated voice evaluation for Simulator testing and development.
//  SFSpeechRecognizer is unavailable on the iOS Simulator.
//

import Foundation

public final class MockVoiceEvaluationService: VoiceEvaluationServiceProtocol {
    
    public init() {}
    
    public func evaluateStream(surah: Int, ayah: Int, expectedWords: [String], maxDuration: TimeInterval) -> AsyncStream<RecitationEvent> {
        AsyncStream { continuation in
            Task {
                // Use expectedWords count if available, otherwise fallback to time-based
                let wordCount = expectedWords.isEmpty
                    ? Int(maxDuration / 0.5)
                    : expectedWords.count
                
                // Simulate detecting words every 0.5 seconds
                for i in 0..<wordCount {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    continuation.yield(.wordDetected(wordIndex: i + 1))
                }
                
                // Randomly generate 0 to 2 mistakes for UI testing
                let mistakeCount = Int.random(in: 0...2)
                var mistakes: [RecitationMistake] = []
                
                if mistakeCount > 0 {
                    for _ in 0..<mistakeCount {
                        let types: [RecitationMistake.MistakeType] = [.tashkil, .tajwid, .memorization]
                        let mistake = RecitationMistake(
                            type: types.randomElement()!,
                            wordIndex: Int.random(in: 1...wordCount),
                            description: "Mock mistake detected."
                        )
                        mistakes.append(mistake)
                    }
                }
                
                continuation.yield(.completed(mistakes: mistakes))
                continuation.finish()
            }
        }
    }
}
