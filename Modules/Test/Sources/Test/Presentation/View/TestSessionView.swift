//
//  TestSessionView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


//
//  TestSessionView.swift
//  Reading
//

import SwiftUI

struct TestSessionView: View {
    @ObservedObject var session: TestSessionManager
    let onFinished: (TestSessionResult) -> Void

    var body: some View {
        VStack(spacing: 24) {
            if session.totalQuestions > 0 {
                ProgressView(value: Double(session.currentQuestionNumber), total: Double(session.totalQuestions))
                Text("Question \(session.currentQuestionNumber) of \(session.totalQuestions)")
                    .font(.headline)
            }

            Spacer()

            if let word = session.activeWord {
                Text(word.text)
                    .font(.system(size: 40))
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, .rightToLeft)
            } else {
                ProgressView()
            }

            if let correct = session.lastWordWasCorrect {
                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(correct ? .green : .red)
                    .font(.title)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Test in progress")
        .onAppear { session.start() }
        .onChange(of: session.phase) { phase in
            if phase == .finished, let result = session.result {
                onFinished(result)
            }
        }
        .onDisappear { session.cancel() }
    }
}