//
//  TestSessionResult.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//
import Foundation

struct TestSessionResult {
    let configuration: TestConfiguration
    var questionResults: [QuestionResult] = []

    var totalQuestions: Int { questionResults.count }
    var correctQuestions: Int { questionResults.filter(\.isFullyCorrect).count }
    var totalWordsRecited: Int { questionResults.reduce(0) { $0 + $1.totalWords } }
    var totalMistakes: Int { questionResults.reduce(0) { $0 + $1.mistakeCount } }

    var scorePercentage: Double {
        guard totalWordsRecited > 0 else { return 0 }
        let correctWords = totalWordsRecited - totalMistakes
        return (Double(correctWords) / Double(totalWordsRecited)) * 100
    }
}


struct QuestionResult {
    let question: TestQuestion
    var wordResults: [WordAttemptResult] = []

    var totalWords: Int { wordResults.count }
    var mistakeCount: Int { wordResults.filter { !$0.isCorrect }.count }
    var isFullyCorrect: Bool { totalWords > 0 && mistakeCount == 0 }
}

struct TestQuestion: Identifiable, Equatable {
    let id = UUID()
    let index: Int
    let startWordId: Int
    let endWordId: Int
    let surah: Int
    let startAyah: Int
    let endAyah: Int

    var ayahCount: Int { endAyah - startAyah + 1 }
}

struct TestConfiguration {
    let scope: TestScope
    let questionCount: Int
}

enum TestScope: Equatable {
    case juz(Int)
    case surahRange(fromSurah: Int, toSurah: Int)
    case ayahRange(surah: Int, fromAyah: Int, toAyah: Int)

    var displayTitle: String {
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


struct AyahUnit: Equatable {
    let surah: Int
    let ayah: Int
    let firstWordId: Int
    let lastWordId: Int
}

struct ResolvedTestRange {
    let scope: TestScope
    let ayahUnits: [AyahUnit]
}
struct WordAttemptResult {
    let word: TestWord
    let spokenText: String?
    let isCorrect: Bool
}
struct TestWord: Equatable {
    let id: Int
    let surah: Int
    let ayah: Int
    let wordPosition: Int
    let text: String

    var isVerseNumberMarker: Bool { wordPosition == 0 }
}
