//
//  TestSessionView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI
import Common

struct TestSessionView: View {
    @ObservedObject var session: TestSessionManager
    @ObservedObject private var fontManager = MushafFontManager.shared
    let onFinished: (TestSessionResult) -> Void
    
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
            if !session.currentQuestionWords.isEmpty {
                AyahCardView(session: session, ayahText: ayahText)
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
        .onChange(of: session.allQuestionsCompleted) { completed in
            if completed {
                showSummarySheet = true
            }
        }
        .onAppear {
            fontManager.registerFonts {
                session.start()
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
    
    private var ayahText: Text {
        let revealedUpTo = session.lastRevealedWordId ?? -1
        
        let initialWordIndices: Set<Int> = {
            var indices = Set<Int>()
            for (index, word) in session.currentQuestionWords.enumerated() {
                let isNumeric = session.numericWordIds.contains(word.id)
                
                if !isNumeric {
                    indices.insert(index)
                    if indices.count == 2 { break }
                }
            }
            return indices
        }()
        
        var result = Text("")
        for (index, word) in session.currentQuestionWords.enumerated() {
            let isNumberWord = session.numericWordIds.contains(word.id)
            
            let isInitialWord = initialWordIndices.contains(index)
            let isRevealed = isNumberWord || isInitialWord || word.id <= revealedUpTo
            let isActive = word.id == session.activeWord?.id
            let wordFont = font(forPage: word.pageNumber)
            
            let segment: Text
            if isRevealed {
                let isLastRevealed = word.id == revealedUpTo
                let color: Color = isLastRevealed ? (session.lastWordWasCorrect == false ? .red : .green) : .primary
                segment = Text(word.text)
                    .font(wordFont)
                    .foregroundColor(color)
            } else {
                let placeholder = Text("⚬ ⚬ ⚬")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary.opacity(0.35))
                segment = isActive ? placeholder.underline() : placeholder
            }
            
            result = index == 0 ? segment : result + Text(" ") + segment
        }
        return result
    }
    
    private func font(forPage page: Int) -> Font {
        if let name = fontManager.fontName(forPage: page, set: .tajweed) {
            return .custom(name, size: 32)
        }
        return .system(size: 32)
    }
}

// MARK: - Ayah Card (scrollable, so long ayahs don't overflow the screen)
private struct AyahCardView: View {
    @ObservedObject var session: TestSessionManager
    let ayahText: Text

    private let topAnchor = "ayahTop"
    private let bottomAnchor = "ayahBottom"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 1).id(topAnchor)

                    ayahText
                        .lineSpacing(10)
                        .multilineTextAlignment(.center)
                        .environment(\.layoutDirection, .rightToLeft)
                        .animation(.easeInOut(duration: 0.3), value: session.lastRevealedWordId)
                        .frame(maxWidth: .infinity)
                        .padding(20)

                    Color.clear.frame(height: 1).id(bottomAnchor)
                }
            }
            .frame(maxHeight: 280)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .padding(.horizontal)
            .onChange(of: session.lastRevealedWordId) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(bottomAnchor, anchor: .bottom)
                }
            }
            .onChange(of: session.currentQuestionNumber) { _ in
                proxy.scrollTo(topAnchor, anchor: .top)
            }
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
