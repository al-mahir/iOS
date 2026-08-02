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
