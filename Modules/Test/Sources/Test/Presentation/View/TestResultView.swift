//
//  TestResultView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import SwiftUI

struct TestResultView: View {
    let result: TestSessionResult

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(result.scorePercentage))% correct")
                        .font(.largeTitle.bold())
                    Text("\(result.correctQuestions) of \(result.totalQuestions) questions recited perfectly")
                        .foregroundStyle(.secondary)
                    Text("\(result.totalMistakes) mistake(s) across \(result.totalWordsRecited) word(s)")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Question breakdown") {
                ForEach(result.questionResults.indices, id: \.self) { i in
                    let questionResult = result.questionResults[i]
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Q\(questionResult.question.index) — Surah \(questionResult.question.surah), Ayah \(questionResult.question.startAyah)–\(questionResult.question.endAyah)")
                                .font(.subheadline.bold())
                            Spacer()
                            Image(systemName: questionResult.isFullyCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(questionResult.isFullyCorrect ? .green : .red)
                        }
                        if questionResult.mistakeCount > 0 {
                            Text("\(questionResult.mistakeCount) mistake(s)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Test Results")
    }
}
