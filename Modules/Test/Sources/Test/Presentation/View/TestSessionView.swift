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
    @State private var showSummarySheet: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Progress Indicator
            if session.totalQuestions > 0 {
                ProgressView(
                    value: Double(session.currentQuestionNumber),
                    total: Double(session.totalQuestions)
                )
                Text(session.isReviewMode ? "Reviewing Question \(session.currentQuestionNumber)" : "Question \(session.currentQuestionNumber) of \(session.totalQuestions)")
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
                // Mic Control Toggle (closed by default; the user turns it on to answer)
                Button {
                    session.isMicMuted.toggle()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: session.isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(session.isMicMuted ? .red : .green)
                        Text(session.isMicMuted ? "Mic Off" : "Mic On")
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
            if !session.isReviewMode {
                Button("Finish Test") {
                    showSummarySheet = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Test in progress")
        .onAppear {
            session.start()
        }
        .onChange(of: session.allQuestionsCompleted) { completed in
            // As soon as every question has been gone through, surface the
            // overview so the user can see what's answered/skipped before
            // moving on to results.
            if completed {
                showSummarySheet = true
            }
        }
        .onDisappear {
            session.cancel()
        }
        // MARK: - Feedback toast for incorrect recitation
        .overlay(alignment: .top) {
            if let feedback = session.wordFeedback {
                WordFeedbackToast(feedback: feedback)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.25), value: session.wordFeedback)
            }
        }
        // MARK: - Questions Summary Sheet
        .sheet(isPresented: $showSummarySheet) {
            QuestionSummaryView(
                session: session,
                onRetryQuestion: { index in
                    showSummarySheet = false
                    session.startReview(questionIndex: index) {
                        // Bring the overview back once the retried question is done.
                        showSummarySheet = true
                    }
                },
                onProceedToResult: {
                    showSummarySheet = false
                    completeAndSubmit()
                }
            )
        }
    }

    // MARK: - Helper Logic
    private func completeAndSubmit() {
        session.finalizeSession()
        if let result = session.result {
            onFinished(result)
        }
    }
}

// MARK: - Word Feedback Toast
private struct WordFeedbackToast: View {
    let feedback: WordFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Not quite right", systemImage: "xmark.circle.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
            Text("You said: \(feedback.spokenText.isEmpty ? "—" : feedback.spokenText)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
            HStack(spacing: 4) {
                Text("Correct:")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                Text(feedback.correctText)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .shadow(radius: 4)
    }
}

// MARK: - Question Summary View Component
struct QuestionSummaryView: View {
    @ObservedObject var session: TestSessionManager
    let onRetryQuestion: (Int) -> Void
    let onProceedToResult: () -> Void

    @State private var showFinishConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(0..<session.totalQuestions, id: \.self) { index in
                        let status = session.statusForQuestion(at: index)
                        let isRetryable = status != .answered

                        Button {
                            guard isRetryable else { return }
                            onRetryQuestion(index)
                        } label: {
                            HStack {
                                Text("Question \(index + 1)")
                                    .font(.body)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Label(
                                    title: { Text(status.title) },
                                    icon: { Image(systemName: status.icon) }
                                )
                                .font(.caption)
                                .foregroundStyle(status.color)

                                if isRetryable {
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .disabled(!isRetryable)
                    }
                } header: {
                    Text("Question Overview")
                } footer: {
                    Text("Tap a skipped or unanswered question to go back and answer it.")
                }
            }
            .navigationTitle("Test Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") {
                        if session.hasSkippedQuestions {
                            showFinishConfirmation = true
                        } else {
                            onProceedToResult()
                        }
                    }
                    .bold()
                }
            }
            // MARK: - Confirmation Alert for Skipped Questions
            .alert("Unanswered / Skipped Questions", isPresented: $showFinishConfirmation) {
                Button("Keep Reviewing", role: .cancel) {}
                Button("Finish Anyway", role: .destructive) {
                    onProceedToResult()
                }
            } message: {
                Text("You still have skipped or unanswered questions. Are you sure you want to finish the test?")
            }
        }
    }
}
