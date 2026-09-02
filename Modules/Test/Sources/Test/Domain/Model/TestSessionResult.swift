//
//  TestSessionResult.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 16/08/2026.
//
import Foundation

public struct TestSessionResult {
    public let configuration: TestConfiguration
    public var questionResults: [QuestionResult] = []

    public var totalQuestions: Int { questionResults.count }
    public var correctQuestions: Int { questionResults.filter(\.isFullyCorrect).count }
    public var totalWordsRecited: Int { questionResults.reduce(0) { $0 + $1.totalWords } }
    public var totalMistakes: Int { questionResults.reduce(0) { $0 + $1.mistakeCount } }

    public var scorePercentage: Double {
        guard totalWordsRecited > 0 else { return 0 }
        let correctWords = totalWordsRecited - totalMistakes
        return (Double(correctWords) / Double(totalWordsRecited)) * 100
    }

    public init(configuration: TestConfiguration, questionResults: [QuestionResult] = []) {
        self.configuration = configuration
        self.questionResults = questionResults
    }
}


public struct QuestionResult {
    public let question: TestQuestion
    public var wordResults: [WordAttemptResult] = []

    public var totalWords: Int { wordResults.count }
    public var mistakeCount: Int { wordResults.filter { !$0.isCorrect }.count }
    public var isFullyCorrect: Bool { totalWords > 0 && mistakeCount == 0 }

    public init(question: TestQuestion, wordResults: [WordAttemptResult] = []) {
        self.question = question
        self.wordResults = wordResults
    }
}

public struct TestQuestion: Identifiable, Equatable {
    public let id = UUID()
    public let index: Int
    public let startWordId: Int
    public let endWordId: Int
    public let surah: Int
    public let startAyah: Int
    public let endAyah: Int

    public var ayahCount: Int { endAyah - startAyah + 1 }

    public init(index: Int, startWordId: Int, endWordId: Int, surah: Int, startAyah: Int, endAyah: Int) {
        self.index = index
        self.startWordId = startWordId
        self.endWordId = endWordId
        self.surah = surah
        self.startAyah = startAyah
        self.endAyah = endAyah
    }
}

public struct TestConfiguration {
    public let scope: TestScope
    public let questionCount: Int

    public init(scope: TestScope, questionCount: Int) {
        self.scope = scope
        self.questionCount = questionCount
    }
}

public enum TestScope: Equatable {
    case juz(Int)
    case surahRange(fromSurah: Int, toSurah: Int)
    case ayahRange(surah: Int, fromAyah: Int, toAyah: Int)

    public var displayTitle: String {
        switch self {
        case .juz(let number):
            return "Juz' \(number)"
        case .surahRange(let from, let to):
            return from == to ? "Surah \(from)" : "Surahs \(from)–\(to)"
        case .ayahRange(let surah, let from, let to):
            return "Surah \(surah), Ayahs \(from)–\(to)"
        }
    }
}


public struct AyahUnit: Equatable {
    public let surah: Int
    public let ayah: Int
    public let firstWordId: Int
    public let lastWordId: Int

    public init(surah: Int, ayah: Int, firstWordId: Int, lastWordId: Int) {
        self.surah = surah
        self.ayah = ayah
        self.firstWordId = firstWordId
        self.lastWordId = lastWordId
    }
}

public struct ResolvedTestRange {
    public let scope: TestScope
    public let ayahUnits: [AyahUnit]

    public init(scope: TestScope, ayahUnits: [AyahUnit]) {
        self.scope = scope
        self.ayahUnits = ayahUnits
    }
}

public struct WordAttemptResult {
    public let word: TestWord
    public let spokenText: String?
    public let isCorrect: Bool

    public init(word: TestWord, spokenText: String?, isCorrect: Bool) {
        self.word = word
        self.spokenText = spokenText
        self.isCorrect = isCorrect
    }
}

public struct TestWord: Equatable {
    public let id: Int
    public let surah: Int
    public let ayah: Int
    public let wordPosition: Int
    public let text: String
    public let pageNumber: Int
    public var isVerseNumberMarker: Bool { wordPosition == 0 }

    public init(id: Int, surah: Int, ayah: Int, wordPosition: Int, text: String, pageNumber: Int) {
        self.id = id
        self.surah = surah
        self.ayah = ayah
        self.wordPosition = wordPosition
        self.text = text
        self.pageNumber = pageNumber
    }
}
