//
//  QuestionResult.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//
import Foundation

struct QuestionResult {
    let question: TestQuestion
    var wordResults: [WordAttemptResult] = []

    var totalWords: Int { wordResults.count }
    var mistakeCount: Int { wordResults.filter { !$0.isCorrect }.count }
    var isFullyCorrect: Bool { totalWords > 0 && mistakeCount == 0 }
}
