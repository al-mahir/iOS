//
//  QraaManager.swift
//  Mushaf
//

import SwiftUI
import Combine

enum QraaStatus: Equatable {
    case idle
    case correct
    case incorrect(expectedWord: QuranWord)

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

/// Where a recitation session should stop.
enum RecitationEndMode: Equatable {
    case endOfPage
    /// Keeps going across page boundaries until the Surah number on the words changes.
    case endOfSurah
}

struct RecitationRange: Equatable {
    let startWordId: Int
    let endMode: RecitationEndMode
}

final class QraaManager: ObservableObject {
    @Published var lastRevealedWordId: Int = Int.max
    @Published var status: QraaStatus = .idle
    @Published var activeTargetWord: QuranWord?
    @Published var lastSpokenText: String?
    @Published var attemptCount: Int = 0
    @Published var pageCompleted: Bool = false
    @Published var isSessionComplete: Bool = false

    private let maxAttempts = 3
    private(set) var currentRange: RecitationRange?
    private var startingSurah: Int?
    private var incorrectDismissWorkItem: DispatchWorkItem?

    let searchRepository: QuranSearchRepository?

    init(searchRepository: QuranSearchRepository? = nil) {
        self.searchRepository = searchRepository
    }

    func updateState(mode: MushafMode, page: MushafPage?) {
        guard let page = page else {
            resetEverything()
            return
        }

        if [.reading, .correction, .muallem].contains(mode) {
            guard currentRange == nil else { return }
            // Find first non-number word
            let firstWord = page.lines.flatMap(\.words).first(where: { !self.isVerseNumber($0) })
            withAnimation {
                lastRevealedWordId = (firstWord?.id ?? 1) - 1
            }
            activeTargetWord = nil
            status = .idle
        } else {
            withAnimation { lastRevealedWordId = Int.max }
            activeTargetWord = nil
            status = .idle
            lastSpokenText = nil
            attemptCount = 0
            currentRange = nil
            isSessionComplete = false
            pageCompleted = false
        }
    }

    private func resetEverything() {
        lastRevealedWordId = Int.max
        activeTargetWord = nil
        status = .idle
        lastSpokenText = nil
        attemptCount = 0
        currentRange = nil
        isSessionComplete = false
        pageCompleted = false
    }

    func endSession() {
        currentRange = nil
        startingSurah = nil
        activeTargetWord = nil
        isSessionComplete = false
        pageCompleted = false
        status = .idle
        lastSpokenText = nil
        attemptCount = 0
    }

    func configureSession(page: MushafPage, range: RecitationRange) {
        currentRange = range
        isSessionComplete = false
        pageCompleted = false
        status = .idle
        lastSpokenText = nil
        attemptCount = 0

        // Get all words
        let allWords = page.lines.flatMap(\.words)
        
        // Get reciteable words (exclude verse numbers)
        let reciteableWords = allWords.filter { !self.isVerseNumber($0) }
        
        startingSurah = reciteableWords.first(where: { $0.id >= range.startWordId })?.surah

        // Find the first target word (skipping verse numbers)
        let firstTargetWord = reciteableWords.first(where: { $0.id >= range.startWordId })
        
        // If there are verse numbers before the first word, reveal them automatically
        let verseNumbersToReveal = allWords
            .filter { $0.id >= range.startWordId && $0.id < (firstTargetWord?.id ?? Int.max) && self.isVerseNumber($0) }
        
        let revealId = verseNumbersToReveal.last?.id ?? (firstTargetWord?.id ?? range.startWordId) - 1
        
        withAnimation {
            lastRevealedWordId = revealId
        }
        
        // Set the active target to the first reciteable word
        activeTargetWord = firstTargetWord
        
        print("▶️ [Qraa] session configured: startWordId=\(range.startWordId) endMode=\(range.endMode)")
        print("▶️ [Qraa] firstTarget='\(activeTargetWord?.text ?? "nil")' (ID: \(activeTargetWord?.id ?? -1))")
    }

    func continueOnNextPage(_ page: MushafPage) {
        pageCompleted = false
        let allWords = page.lines.flatMap(\.words).filter { !self.isVerseNumber($0) }

        guard let first = allWords.first else { return }

        if let startingSurah, first.surah != startingSurah {
            isSessionComplete = true
            activeTargetWord = nil
            return
        }

        // Auto-reveal any leading verse numbers before the first word
        let leadingVerseNumbers = page.lines.flatMap(\.words)
            .filter { $0.id < first.id && self.isVerseNumber($0) }
        
        let revealId = leadingVerseNumbers.last?.id ?? first.id - 1
        
        withAnimation {
            lastRevealedWordId = revealId
        }
        activeTargetWord = first
        attemptCount = 0
        status = .idle
    }

    // MARK: - Advance Target Word & Skip Ayah End Symbols

    func updateTargetWord(page: MushafPage) {
        let allPageWords = page.lines.flatMap(\.words)
        attemptCount = 0

        // Find the next reciteable word (ignoring verse numbers and string numbers)
        let nextReciteableWord = allPageWords.first { $0.id > lastRevealedWordId && !self.isVerseNumber($0) }

        if let nextWord = nextReciteableWord {
            // Auto-reveal any intermediate verse number symbols before the next reciteable word
            let endSymbolsToReveal = allPageWords.filter { $0.id > lastRevealedWordId && $0.id < nextWord.id && self.isVerseNumber($0) }
            if let highestSymbol = endSymbolsToReveal.last {
                withAnimation {
                    lastRevealedWordId = highestSymbol.id
                }
            }
        } else {
            // If there are remaining verse end symbols at the end of the page/surah, reveal them too
            let trailingSymbols = allPageWords.filter { $0.id > lastRevealedWordId && self.isVerseNumber($0) }
            if let lastSymbol = trailingSymbols.last {
                withAnimation {
                    lastRevealedWordId = lastSymbol.id
                }
            }
        }

        guard let range = currentRange else {
            activeTargetWord = nextReciteableWord
            if nextReciteableWord == nil { status = .idle }
            return
        }

        guard let next = nextReciteableWord else {
            switch range.endMode {
            case .endOfPage:
                isSessionComplete = true
                activeTargetWord = nil
            case .endOfSurah:
                pageCompleted = true
                activeTargetWord = nil
            }
            return
        }

        if range.endMode == .endOfSurah, let startingSurah, next.surah != startingSurah {
            isSessionComplete = true
            activeTargetWord = nil
            return
        }

        activeTargetWord = next
        print("🎯 [Qraa] new target word: '\(next.text)' (ID: \(next.id))")
    }

    // MARK: - Helper Functions to Detect Verse Numbers

    private func isVerseNumber(_ word: QuranWord) -> Bool {
        if word.wordPosition == 0 {
            return true
        }

        if let searchWord = searchRepository?.fetchSearchWord(id: word.id) {
            let normalized = searchWord.normalized.trimmingCharacters(in: .whitespacesAndNewlines)
            let display = searchWord.display.trimmingCharacters(in: .whitespacesAndNewlines)

            if isNumericString(normalized) || isNumericString(display) {
                return true
            }
        }

        let text = word.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return isNumericString(text)
    }

    private func isNumericString(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        let numberCharacters = CharacterSet(charactersIn: "0123456789٠١٢٣٤٥٦٧٨٩")
        return text.unicodeScalars.allSatisfy { numberCharacters.contains($0) }
    }

    /// Check if a word is a reciteable word (not a verse number)
    private func isReciteableWord(_ word: QuranWord) -> Bool {
        return !isVerseNumber(word)
    }

    // MARK: - Speech Evaluation Logic

    func evaluateSpokenWord(_ spokenWord: String, targetWord: QuranWord, currentPage: MushafPage) {
        // Check if the target word is a verse number or string number — skip immediately
        if isVerseNumber(targetWord) {
            print("⚠️ [Qraa] Target word ID \(targetWord.id) is a verse/string number! Skipping...")
            withAnimation {
                lastRevealedWordId = targetWord.id
            }
            updateTargetWord(page: currentPage)
            return
        }

        // Strip invisible Unicode RTL/LTR control marks injected by Apple Speech
        let cleanedSpoken = spokenWord.unicodeScalars
            .filter { $0.value != 0x200F && $0.value != 0x200E && !$0.properties.isDefaultIgnorableCodePoint }
            .map(Character.init)
            .reduce(into: "") { $0.append($1) }
            .trimmingCharacters(in: .whitespacesAndNewlines)

        print("📝 [Qraa] evaluating '\(cleanedSpoken)' against target ID \(targetWord.id) (attempt \(attemptCount + 1))")
        lastSpokenText = cleanedSpoken
        attemptCount += 1

        // Get the expected words from the search database
        guard let searchWord = searchRepository?.fetchSearchWord(id: targetWord.id) else {
            print("❌ [Qraa] No search data found for word ID \(targetWord.id)")
            status = .incorrect(expectedWord: targetWord)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            let workItem = DispatchWorkItem { [weak self] in
                guard let self, case .incorrect = self.status else { return }
                withAnimation { self.status = .idle }
            }
            incorrectDismissWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: workItem)
            return
        }

        let displayText = searchWord.display.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedText = searchWord.normalized.trimmingCharacters(in: .whitespacesAndNewlines)

        // Safety check: if DB text turns out to be a number string ("1", "2", etc.)
        if isNumericString(normalizedText) || isNumericString(displayText) {
            print("⚠️ [Qraa] Target word ID \(targetWord.id) returned string number ('\(normalizedText)'/'\(displayText)'). Skipping...")
            withAnimation {
                lastRevealedWordId = targetWord.id
            }
            updateTargetWord(page: currentPage)
            return
        }

        print("🔍 [Qraa] Checking against display: '\(displayText)' and normalized: '\(normalizedText)'")

        let isMatch = cleanedSpoken == displayText || cleanedSpoken == normalizedText

        if isMatch {
            print("✅ [Qraa] MATCH - revealing QPC font word ID \(targetWord.id)")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                status = .correct
                lastRevealedWordId = targetWord.id
            }

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            updateTargetWord(page: currentPage)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self, case .correct = self.status else { return }
                withAnimation {
                    self.status = .idle
                    self.lastSpokenText = nil
                    self.attemptCount = 0
                }
            }
        } else {
            print("❌ [Qraa] NO MATCH - got '\(cleanedSpoken)', expected display: '\(displayText)' or normalized: '\(normalizedText)'")
            status = .incorrect(expectedWord: targetWord)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

            let workItem = DispatchWorkItem { [weak self] in
                guard let self, case .incorrect = self.status else { return }
                withAnimation { self.status = .idle }
            }
            incorrectDismissWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: workItem)
        }
    }

    func getDisplayCorrection(for word: QuranWord) -> String {
        if let searchWord = searchRepository?.fetchSearchWord(id: word.id) {
            return searchWord.display.isEmpty ? searchWord.normalized : searchWord.display
        }
        return word.text
    }
}
