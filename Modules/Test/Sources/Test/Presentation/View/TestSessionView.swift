//
//  TestSessionView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI

struct TestSessionView: View {
    @ObservedObject var session: TestSessionManager
    let onFinished: (TestSessionResult) -> Void

    // MARK: - State Management
    @State private var isMicMuted: Bool = true
    @State private var showFinishConfirmation: Bool = false
    @State private var showSummarySheet: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Progress Indicator
            if session.totalQuestions > 0 {
                ProgressView(
                    value: Double(session.currentQuestionNumber),
                    total: Double(session.totalQuestions)
                )
                Text("Question \(session.currentQuestionNumber) of \(session.totalQuestions)")
                    .font(.headline)
            }

            Spacer()

            // MARK: - Active Question View
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

            // MARK: - Controls (Mic & Skip)
            HStack(spacing: 32) {
                // Mic Control Toggle (Defaults to Off)
                Button {
                    isMicMuted.toggle()
                    // If your TestSessionManager controls live audio input, toggle it here:
                    // session.setMicrophoneEnabled(!isMicMuted)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(isMicMuted ? .red : .green)
                        Text(isMicMuted ? "Mic Off" : "Mic On")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
                }

                // Skip Question Button
                Button {
                    session.skipQuestion()
                } label: {
                    HStack {
                        Text("Skip Question")
                        Image(systemName: "forward.fill")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // MARK: - Manual Finish Trigger
            Button("Finish Test") {
                handleFinishAttempt()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Test in progress")
        .onAppear {
            session.start()
        }
        .onChange(of: session.phase) { phase in
            if phase == .finished {
                handleFinishAttempt()
            }
        }
        .onDisappear {
            session.cancel()
        }
        // MARK: - Confirmation Alert for Skipped Questions
        .alert("Unanswered / Skipped Questions", isPresented: $showFinishConfirmation) {
            Button("Review Answers", role: .cancel) {
                showSummarySheet = true
            }
            Button("Finish Anyway", role: .destructive) {
                completeAndSubmit()
            }
        } message: {
            Text("You have skipped questions remaining. Are you sure you want to finish the test?")
        }
        // MARK: - Questions Summary Sheet
        .sheet(isPresented: $showSummarySheet) {
            QuestionSummaryView(
                session: session,
                onProceedToResult: {
                    showSummarySheet = false
                    completeAndSubmit()
                }
            )
        }
    }

    // MARK: - Helper Logic
    private func handleFinishAttempt() {
        if session.hasSkippedQuestions {
            showFinishConfirmation = true
        } else {
            showSummarySheet = true
        }
    }

    private func completeAndSubmit() {
        if let result = session.result {
            onFinished(result)
        }
    }
}

// MARK: - Question Summary View Component
struct QuestionSummaryView: View {
    @ObservedObject var session: TestSessionManager
    let onProceedToResult: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Question Overview")) {
                    ForEach(0..<session.totalQuestions, id: \.self) { index in
                        let status = session.statusForQuestion(at: index)
                        HStack {
                            Text("Question \(index + 1)")
                                .font(.body)

                            Spacer()

                            Label(
                                title: { Text(status.title) },
                                icon: { Image(systemName: status.icon) }
                            )
                            .font(.caption)
                            .foregroundStyle(status.color)
                        }
                    }
                }
            }
            .navigationTitle("Test Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("See Results") {
                        onProceedToResult()
                    }
                    .bold()
                }
            }
        }
    }
}
