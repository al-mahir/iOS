// MuallemMockDataSource.swift
// Mualem

import Foundation

final class MuallemMockDataSource {
    var mockErrorRate: Double = 0.2
    private var activeContinuation: AsyncStream<MuallemSessionEvent>.Continuation?
    private var currentConfig: MuallemWSSessionConfig?
    
    func simulateSession(config: MuallemWSSessionConfig) -> AsyncStream<MuallemSessionEvent> {
        self.currentConfig = config
        return AsyncStream { continuation in
            self.activeContinuation = continuation
            Task {
                // Simulate connection ack
                try? await Task.sleep(nanoseconds: 100_000_000)
                continuation.yield(.sessionAck(sessionId: "mock-session-\(UUID().uuidString.prefix(8))", engine: "mock (offline)", sampleRate: 16000))
            }
        }
    }
    
    func finishMockSession() {
        guard let continuation = activeContinuation, let config = currentConfig else { return }
        let mockWords = Self.generateMockWords(
            sura: config.sura,
            aya: config.aya,
            errorRate: self.mockErrorRate
        )
        
        let mockFeedback = RecitationFeedback(
            chunkSeq: 1,
            status: .ok,
            words: mockWords,
            cursor: QuranPosition(sura: config.sura, aya: config.aya, wordIdx: mockWords.count),
            uthmaniText: mockWords.map { $0.uthmani }.joined(separator: " "),
            nonVerse: [],
            forcedCut: false
        )
        
        continuation.yield(.feedback(mockFeedback))
        continuation.yield(.done)
        continuation.finish()
        
        activeContinuation = nil
        currentConfig = nil
    }
    
    // MARK: - Mock Word Generation (Al-Fatihah Ayahs 1–7)
    
    private static let fatihaAyahs: [Int: [String]] = [
        1: ["بِسْمِ", "ٱللَّهِ", "ٱلرَّحْمَٰنِ", "ٱلرَّحِيمِ"],
        2: ["ٱلْحَمْدُ", "لِلَّهِ", "رَبِّ", "ٱلْعَٰلَمِينَ"],
        3: ["ٱلرَّحْمَٰنِ", "ٱلرَّحِيمِ"],
        4: ["مَٰلِكِ", "يَوْمِ", "ٱلدِّينِ"],
        5: ["إِيَّاكَ", "نَعْبُدُ", "وَإِيَّاكَ", "نَسْتَعِينُ"],
        6: ["ٱهْدِنَا", "ٱلصِّرَٰطَ", "ٱلْمُسْتَقِيمَ"],
        7: ["صِرَٰطَ", "ٱلَّذِينَ", "أَنْعَمْتَ", "عَلَيْهِمْ", "غَيْرِ", "ٱلْمَغْضُوبِ", "عَلَيْهِمْ", "وَلَا", "ٱلضَّآلِّينَ"]
    ]
    
    private static func generateMockWords(sura: Int, aya: Int, errorRate: Double) -> [WordFeedback] {
        let rawWords: [String]
        if sura == 1, let ayWords = fatihaAyahs[aya] {
            rawWords = ayWords
        } else {
            rawWords = ["كلمة1", "كلمة2", "كلمة3", "كلمة4"]
        }
        
        return rawWords.enumerated().map { (idx, uthmani) in
            let roll = Double.random(in: 0...1)
            let status: WordFeedbackStatus
            let errors: [WordError]
            
            if roll < errorRate {
                status = .error
                errors = [
                    WordError(
                        errorType: .tajweed,
                        speechErrorType: .replace,
                        uthmaniPos: [0, 2],
                        expectedPh: "aa",
                        predictedPh: "a",
                        expectedLen: 2,
                        predictedLen: 1,
                        tajweedRules: [
                            TajweedRuleFinding(
                                nameAr: "مد طبيعي",
                                nameEn: "Natural Madd",
                                goldenLen: 2,
                                correctnessType: "count",
                                tag: "madd_tabii"
                            )
                        ],
                        confidence: .known(0.85)
                    )
                ]
            } else {
                status = .correct
                errors = []
            }
            
            return WordFeedback(
                sura: sura,
                aya: aya,
                wordIdx: idx,
                uthmani: uthmani,
                status: status,
                isTrimmed: false,
                errors: errors
            )
        }
    }
    
    // MARK: - Mock REST Data
    
    func mockHealth() -> AIHealthInfo {
        return AIHealthInfo(status: "offline", defaultEngine: "mock (offline)", availableEngines: ["mock"])
    }
    
    func mockTajweedRules() -> [TajweedRuleConfig] {
        return [
            TajweedRuleConfig(key: "ghunnah", nameAr: "غنة", nameEn: "Ghunnah", kind: .tajweed),
            TajweedRuleConfig(key: "madd_tabii", nameAr: "مد طبيعي", nameEn: "Natural Madd", kind: .tajweed)
        ]
    }
    
    func mockMoshafSchema() -> [MoshafSchemaField] {
        return []
    }
}
