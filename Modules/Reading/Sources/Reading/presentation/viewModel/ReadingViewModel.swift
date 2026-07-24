////
////  ReadingViewModel.swift
////  Reading
////
////  Created by Basmala Abuzied Ahmed on 24/07/2026.
////
//
//import SwiftUI
//import Combine
//import Mushaf
//
//public enum QraaStatus: Equatable {
//    case idle
//    case correct
//    case incorrect(expectedWord: QuranWord)
//
//    public static func == (lhs: QraaStatus, rhs: QraaStatus) -> Bool {
//        switch (lhs, rhs) {
//        case (.idle, .idle): return true
//        case (.correct, .correct): return true
//        case (.incorrect(let word1), .incorrect(let word2)): return word1.id == word2.id
//        default: return false
//        }
//    }
//}
//
//public enum RecitationEndMode: Equatable {
//    case endOfPage
//    case endOfSurah
//}
//
//public struct RecitationRange: Equatable {
//    public let startWordId: Int
//    public let endMode: RecitationEndMode
//    public init(startWordId: Int, endMode: RecitationEndMode) {
//        self.startWordId = startWordId
//        self.endMode = endMode
//    }
//}
//
//public final class ReadingViewModel: ObservableObject {
//    @Published public var lastRevealedWordId: Int = Int.max
//    @Published public var status: QraaStatus = .idle
//    @Published public var activeTargetWord: QuranWord?
//    @Published public var lastSpokenText: String?
//    @Published public var attemptCount: Int = 0
//    @Published public var pageCompleted: Bool = false
//    @Published public var isSessionComplete: Bool = false
//    @Published public private(set) var isReadingModeActive: Bool = false
//
//    private let maxAttempts = 3
//    private(set) var currentRange: RecitationRange?
//    private var startingSurah: Int?
//    private var incorrectDismissWorkItem: DispatchWorkItem?
//
//    let searchRepository: QuranSearchRepository?
//
//    public init(searchRepository: QuranSearchRepository? = nil) {
//        self.searchRepository = searchRepository
//    }
//
//    // MARK: - Lifecycle (mirrors ListeningViewModel's activate/deactivate)
//
//    /// Call when the user switches selectedMode to .reading/.correction/.muallem.
//    public func activateReadingMode(page: MushafPage?) {
//        isReadingModeActive = true
//        guard let page else {
//            resetEverything()
//            return
//        }
//        guard currentRange == nil else { return } // a session is already running
//
//        let allWords = page.lines.flatMap(\.words)
//        let reciteableWords = allWords.filter { !self.isVerseNumber($0) }
//        guard let firstWord = reciteableWords.first else { return }
//
//        configureSession(page: page, range: RecitationRange(startWordId: firstWord.id, endMode: .endOfPage))
//    }
//
//    /// Call when the user switches away from reading modes.
//    public func deactivateReadingMode() {
//        isReadingModeActive = false
//        resetEverything()
//    }
//
//    private func resetEverything() {
//        withAnimation { lastRevealedWordId = Int.max }
//        activeTargetWord = nil
//        status = .idle
//        lastSpokenText = nil
//        attemptCount = 0
//        currentRange = nil
//        isSessionComplete = false
//        pageCompleted = false
//    }
//
//    public func configureSession(page: MushafPage, range: RecitationRange) {
//        currentRange = range
//        isSessionComplete = false
//        pageCompleted = false
//        status = .idle
//        lastSpokenText = nil
//        attemptCount = 0
//
//        let allWords = page.lines.flatMap(\.words)
//        let reciteableWords = allWords.filter { !self.isVerseNumber($0) }
//
//        startingSurah = reciteableWords.first(where: { $0.id >= range.startWordId })?.surah
//        let firstTargetWord = reciteableWords.first(where: { $0.id >= range.startWordId })
//
//        let verseNumbersToReveal = allWords
//            .filter { $0.id >= range.startWordId && $0.id < (firstTargetWord?.id ?? Int.max) && self.isVerseNumber($0) }
//        let revealId = verseNumbersToReveal.last?.id ?? (firstTargetWord?.id ?? range.startWordId) - 1
//
//        withAnimation { lastRevealedWordId = revealId }
//        activeTargetWord = firstTargetWord
//    }
//
//    /// Call from MushafView when a new page has finished loading while a
//    /// cross-page (endOfSurah) session is still active.
//    public func continueOnNextPage(_ page: MushafPage) {
//        pageCompleted = false
//        let allWords = page.lines.flatMap(\.words).filter { !self.isVerseNumber($0) }
//        guard let first = allWords.first else { return }
//
//        if let startingSurah, first.surah != startingSurah {
//            isSessionComplete = true
//            activeTargetWord = nil
//            return
//        }
//
//        let leadingVerseNumbers = page.lines.flatMap(\.words)
//            .filter { $0.id < first.id && self.isVerseNumber($0) }
//        let revealId = leadingVerseNumbers.last?.id ?? first.id - 1
//
//        withAnimation { lastRevealedWordId = revealId }
//        activeTargetWord = first
//        attemptCount = 0
//        status = .idle
//    }
//
//    // MARK: - Advance Target Word & Skip Ayah End Symbols
//
//    public func updateTargetWord(page: MushafPage) {
//        let allPageWords = page.lines.flatMap(\.words)
//        attemptCount = 0
//
//        let nextReciteableWord = allPageWords.first { $0.id > lastRevealedWordId && !self.isVerseNumber($0) }
//
//        if let nextWord = nextReciteableWord {
//            let endSymbolsToReveal = allPageWords.filter { $0.id > lastRevealedWordId && $0.id < nextWord.id && self.isVerseNumber($0) }
//            if let highestSymbol = endSymbolsToReveal.last {
//                withAnimation { lastRevealedWordId = highestSymbol.id }
//            }
//        } else {
//            let trailingSymbols = allPageWords.filter { $0.id > lastRevealedWordId && self.isVerseNumber($0) }
//            if let lastSymbol = trailingSymbols.last {
//                withAnimation { lastRevealedWordId = lastSymbol.id }
//            }
//        }
//
//        guard let range = currentRange else {
//            activeTargetWord = nextReciteableWord
//            if nextReciteableWord == nil { status = .idle }
//            return
//        }
//
//        guard let next = nextReciteableWord else {
//            switch range.endMode {
//            case .endOfPage:
//                isSessionComplete = true
//                activeTargetWord = nil
//            case .endOfSurah:
//                pageCompleted = true
//                activeTargetWord = nil
//            }
//            return
//        }
//
//        if range.endMode == .endOfSurah, let startingSurah, next.surah != startingSurah {
//            isSessionComplete = true
//            activeTargetWord = nil
//            return
//        }
//
//        activeTargetWord = next
//    }
//
//    // MARK: - Verse number detection
//
//    private func isVerseNumber(_ word: QuranWord) -> Bool {
//        if word.wordPosition == 0 { return true }
//
//        if let searchWord = searchRepository?.fetchSearchWord(id: word.id) {
//            let normalized = searchWord.normalized.trimmingCharacters(in: .whitespacesAndNewlines)
//            let display = searchWord.display.trimmingCharacters(in: .whitespacesAndNewlines)
//            if isNumericString(normalized) || isNumericString(display) { return true }
//        }
//
//        let text = word.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        return isNumericString(text)
//    }
//
//    private func isNumericString(_ text: String) -> Bool {
//        guard !text.isEmpty else { return false }
//        let numberCharacters = CharacterSet(charactersIn: "0123456789٠١٢٣٤٥٦٧٨٩")
//        return text.unicodeScalars.allSatisfy { numberCharacters.contains($0) }
//    }
//
//    // MARK: - Speech Evaluation
//
//    public func evaluateSpokenWord(_ spokenWord: String, targetWord: QuranWord, currentPage: MushafPage) {
//        if isVerseNumber(targetWord) {
//            withAnimation { lastRevealedWordId = targetWord.id }
//            updateTargetWord(page: currentPage)
//            return
//        }
//
//        let cleanedSpoken = spokenWord.unicodeScalars
//            .filter { $0.value != 0x200F && $0.value != 0x200E && !$0.properties.isDefaultIgnorableCodePoint }
//            .map(Character.init)
//            .reduce(into: "") { $0.append($1) }
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//
//        lastSpokenText = cleanedSpoken
//        attemptCount += 1
//
//        guard let searchWord = searchRepository?.fetchSearchWord(id: targetWord.id) else {
//            failAttempt(targetWord: targetWord)
//            return
//        }
//
//        let displayText = searchWord.display.trimmingCharacters(in: .whitespacesAndNewlines)
//        let normalizedText = searchWord.normalized.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        if isNumericString(normalizedText) || isNumericString(displayText) {
//            withAnimation { lastRevealedWordId = targetWord.id }
//            updateTargetWord(page: currentPage)
//            return
//        }
//
//        let isMatch = cleanedSpoken == displayText || cleanedSpoken == normalizedText
//
//        if isMatch {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                status = .correct
//                lastRevealedWordId = targetWord.id
//            }
//            UINotificationFeedbackGenerator().notificationOccurred(.success)
//            updateTargetWord(page: currentPage)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
//                guard let self, case .correct = self.status else { return }
//                withAnimation {
//                    self.status = .idle
//                    self.lastSpokenText = nil
//                    self.attemptCount = 0
//                }
//            }
//        } else {
//            failAttempt(targetWord: targetWord)
//        }
//    }
//
//    private func failAttempt(targetWord: QuranWord) {
//        status = .incorrect(expectedWord: targetWord)
//        UINotificationFeedbackGenerator().notificationOccurred(.error)
//
//        let workItem = DispatchWorkItem { [weak self] in
//            guard let self, case .incorrect = self.status else { return }
//            withAnimation { self.status = .idle }
//        }
//        incorrectDismissWorkItem = workItem
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: workItem)
//    }
//
//    public func getDisplayCorrection(for word: QuranWord) -> String {
//        if let searchWord = searchRepository?.fetchSearchWord(id: word.id) {
//            return searchWord.display.isEmpty ? searchWord.normalized : searchWord.display
//        }
//        return word.text
//    }
//}
