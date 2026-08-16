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
                
                let engineName = NSLocalizedString(
                    "mock_engine_offline",
                    bundle: .module,
                    value: "mock (offline)",
                    comment: "Name for mock offline engine"
                )
                
                continuation.yield(.sessionAck(
                    sessionId: "mock-session-\(UUID().uuidString.prefix(8))",
                    engine: engineName,
                    sampleRate: 16000
                ))
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
            let defaultWord1 = NSLocalizedString("mock_word_1", bundle: .module, value: "كلمة1", comment: "Mock word placeholder 1")
            let defaultWord2 = NSLocalizedString("mock_word_2", bundle: .module, value: "كلمة2", comment: "Mock word placeholder 2")
            let defaultWord3 = NSLocalizedString("mock_word_3", bundle: .module, value: "كلمة3", comment: "Mock word placeholder 3")
            let defaultWord4 = NSLocalizedString("mock_word_4", bundle: .module, value: "كلمة4", comment: "Mock word placeholder 4")
            rawWords = [defaultWord1, defaultWord2, defaultWord3, defaultWord4]
        }
        
        return rawWords.enumerated().map { (idx, uthmani) in
            let roll = Double.random(in: 0...1)
            let status: WordFeedbackStatus
            let errors: [WordError]
            
            if roll < errorRate {
                status = .error
                
                let maddAr = NSLocalizedString("madd_tabii_ar", bundle: .module, value: "مد طبيعي", comment: "Arabic rule name for Madd Tabii")
                let maddEn = NSLocalizedString("madd_tabii_en", bundle: .module, value: "Natural Madd", comment: "English rule name for Madd Tabii")
                
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
                                nameAr: maddAr,
                                nameEn: maddEn,
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
        let statusStr = NSLocalizedString("mock_status_offline", bundle: .module, value: "offline", comment: "Mock health status")
        let engineStr = NSLocalizedString("mock_engine_offline", bundle: .module, value: "mock (offline)", comment: "Mock default engine")
        return AIHealthInfo(status: statusStr, defaultEngine: engineStr, availableEngines: ["mock"])
    }
    
    func mockTajweedRules() -> [TajweedRuleConfig] {
        let ghunnahAr = NSLocalizedString("ghunnah_ar", bundle: .module, value: "غنة", comment: "Ghunnah Arabic")
        let ghunnahEn = NSLocalizedString("ghunnah_en", bundle: .module, value: "Ghunnah", comment: "Ghunnah English")
        let maddAr = NSLocalizedString("madd_tabii_ar", bundle: .module, value: "مد طبيعي", comment: "Madd Tabii Arabic")
        let maddEn = NSLocalizedString("madd_tabii_en", bundle: .module, value: "Natural Madd", comment: "Madd Tabii English")
        
        return [
            TajweedRuleConfig(key: "ghunnah", nameAr: ghunnahAr, nameEn: ghunnahEn, kind: .tajweed),
            TajweedRuleConfig(key: "madd_tabii", nameAr: maddAr, nameEn: maddEn, kind: .tajweed)
        ]
    }
    
    func mockMoshafSchema() -> [MoshafSchemaField] {
        return []
    }
}
