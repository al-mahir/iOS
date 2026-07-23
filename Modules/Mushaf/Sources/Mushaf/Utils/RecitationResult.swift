import SwiftUI
import Combine

enum QraaStatus: Equatable {
    case idle
    case correct
    case incorrect(expectedWord: QuranWord)
    
    // Manual Equatable conformance because of associated value
    static func == (lhs: QraaStatus, rhs: QraaStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.correct, .correct):
            return true
        case (.incorrect(let word1), .incorrect(let word2)):
            return word1.id == word2.id
        default:
            return false
        }
    }
}

final class QraaManager: ObservableObject {
    @Published var lastRevealedWordId: Int = Int.max
    @Published var status: QraaStatus = .idle
    @Published var activeTargetWord: QuranWord?
    @Published var lastSpokenText: String?
    
    // Track attempts for current word
    @Published var attemptCount: Int = 0
    private let maxAttempts = 3
    
    func updateState(mode: MushafMode, page: MushafPage?) {
        guard let page = page else {
            lastRevealedWordId = Int.max
            activeTargetWord = nil
            status = .idle
            lastSpokenText = nil
            attemptCount = 0
            return
        }
        
        if [.reading, .correction, .muallem].contains(mode) {
            // Find first non-symbol word
            if let firstWord = page.lines
                .flatMap(\.words)
                .first(where: { $0.wordPosition != 0 }) {
                
                withAnimation {
                    lastRevealedWordId = firstWord.id - 1
                }
                activeTargetWord = firstWord
                status = .idle
                lastSpokenText = nil
                attemptCount = 0
            }
        } else {
            // Reveal all words when in non-recitation modes
            withAnimation {
                lastRevealedWordId = Int.max
            }
            activeTargetWord = nil
            status = .idle
            lastSpokenText = nil
            attemptCount = 0
        }
    }
    
    func updateTargetWord(page: MushafPage) {
        let allWords = page.lines.flatMap(\.words)
        activeTargetWord = allWords.first { $0.id > lastRevealedWordId && $0.wordPosition != 0 }
        
        if activeTargetWord == nil {
            // All words revealed - completion
            status = .idle
        }
        attemptCount = 0
    }
    
    func evaluateSpokenWord(_ spokenWord: String, targetWord: QuranWord, currentPage: MushafPage) {
        print("📝 Evaluating: '\(spokenWord)' against '\(targetWord.text)'")
        lastSpokenText = spokenWord
        attemptCount += 1
        
        // 1. Try strict phonetic matching
        var isMatch = ArabicPhoneticMatcher.isPhoneticMatch(spokenWord, targetWord.text)
        print("🔍 Strict match: \(isMatch)")
        
        // 2. If not matched, try without diacritics
        if !isMatch {
            let spokenNoDiacritics = ArabicPhoneticMatcher.normalizeArabic(spokenWord)
            let expectedNoDiacritics = ArabicPhoneticMatcher.normalizeArabic(targetWord.text)
            if spokenNoDiacritics == expectedNoDiacritics {
                isMatch = true
                print("🔍 Match without diacritics: \(spokenNoDiacritics) == \(expectedNoDiacritics)")
            }
        }
        
        // 3. Try matching with Arabic prefixes/suffixes stripped
        if !isMatch {
            let prefixes = ["ال", "و", "ف", "ب", "ل", "ك", "س"]
            let suffixes = ["ه", "هم", "ها", "كم", "كن", "نا", "ي"]
            
            var spokenStripped = spokenWord
            var expectedStripped = targetWord.text
            
            for prefix in prefixes {
                if spokenStripped.hasPrefix(prefix) {
                    spokenStripped = String(spokenStripped.dropFirst(prefix.count))
                }
                if expectedStripped.hasPrefix(prefix) {
                    expectedStripped = String(expectedStripped.dropFirst(prefix.count))
                }
            }
            
            for suffix in suffixes {
                if spokenStripped.hasSuffix(suffix) {
                    spokenStripped = String(spokenStripped.dropLast(suffix.count))
                }
                if expectedStripped.hasSuffix(suffix) {
                    expectedStripped = String(expectedStripped.dropLast(suffix.count))
                }
            }
            
            if ArabicPhoneticMatcher.isPhoneticMatch(spokenStripped, expectedStripped) {
                isMatch = true
                print("🔍 Match after stripping: \(spokenStripped) == \(expectedStripped)")
            }
        }
        
        // 4. Fuzzy match with higher tolerance after multiple attempts
        if !isMatch && attemptCount >= maxAttempts {
            let distance = ArabicPhoneticMatcher.levenshteinDistance(
                ArabicPhoneticMatcher.normalizeArabic(spokenWord),
                ArabicPhoneticMatcher.normalizeArabic(targetWord.text)
            )
            let tolerance = attemptCount >= maxAttempts + 2 ? 3 : 2
            if distance <= tolerance {
                isMatch = true
                print("🔍 Fuzzy match with distance: \(distance) <= \(tolerance)")
            }
        }
        
        // ✅ HANDLE MATCH - CORRECT ANSWER
        if isMatch {
            print("✅ MATCH FOUND! Revealing word: \(targetWord.text)")
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                status = .correct
                lastRevealedWordId = targetWord.id
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            updateTargetWord(page: currentPage)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                withAnimation {
                    self?.status = .idle
                    self?.lastSpokenText = nil
                    self?.attemptCount = 0
                }
            }
        }
        
        // ❌ HANDLE ERROR - WRONG ANSWER
        else {
            print("❌ NO MATCH! Showing error for: \(targetWord.text)")
            status = .incorrect(expectedWord: targetWord)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}
