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
    let onExitTestFlow: () -> Void

    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    @State private var showSummarySheet: Bool = false
    @State private var showExitConfirmation: Bool = false

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // MARK: - Progress Indicator
            if session.totalQuestions > 0 {
                progressHeader
            }

            Spacer()

            // MARK: - Active Question View
            if !session.currentQuestionWords.isEmpty {
                AyahCardView(session: session, ayahText: ayahText)
            } else {
                ProgressView()
                    .tint(dsColors.primary)
            }

            if let correct = session.lastWordWasCorrect {
                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(correct ? dsColors.success : dsColors.error)
                    .font(.title)
            }

            Spacer()

            // MARK: - Controls (Mic & Skip)
            HStack(spacing: DSSpacing.lg) {
                Button {
                    session.isMicMuted.toggle()
                } label: {
                    VStack(spacing: DSSpacing.xs) {
                        Image(systemName: session.isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(session.isMicMuted ? dsColors.error : dsColors.success)
                        Text(session.isMicMuted ? "Mic Off" : "Mic On", bundle: .module)
                            .dsFont(DSTypography.labelSmall)
                            .foregroundStyle(dsColors.textSecondary)
                    }
                    .frame(width: 64, height: 64)
                    .background(session.isMicMuted ? dsColors.errorContainer : dsColors.successContainer)
                    .clipShape(Circle())
                }

                // Skip Question Button
                Button {
                    session.skipQuestion()
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Text("Skip Question", bundle: .module)
                        Image(systemName: "forward.fill")
                    }
                    .dsFont(DSTypography.buttonText)
                    .padding(.vertical, DSSpacing.smMd)
                    .frame(maxWidth: .infinity)
                    .background(dsColors.warningContainer)
                    .foregroundStyle(dsColors.warning)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                }
            }

            // MARK: - Manual Finish Trigger
            if !session.isReviewMode {
                Button {
                    showSummarySheet = true
                } label: {
                    Text("Finish Test", bundle: .module)
                }
                .dsFont(DSTypography.bodyMedium)
                .foregroundStyle(dsColors.textSecondary)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.background.ignoresSafeArea())
        .navigationTitle(Text("Test in progress", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .alert(
            Text("Leave Test?", bundle: .module, comment: "Title of the confirmation alert shown when the user tries to leave an in-progress test"),
            isPresented: $showExitConfirmation
        ) {
            Button(role: .cancel) {} label: {
                Text("Keep Testing", bundle: .module, comment: "Alert action that dismisses the leave-test confirmation and stays on the test")
            }
            Button(role: .destructive) {
                onExitTestFlow()
            } label: {
                Text("Leave", bundle: .module, comment: "Alert action that confirms leaving the in-progress test, discarding progress")
            }
        } message: {
            Text("Are you sure you want to leave? Your progress in this test will be lost.", bundle: .module, comment: "Body of the confirmation alert shown when the user tries to leave an in-progress test")
        }
        .onChange(of: session.allQuestionsCompleted) { completed in
            if completed {
                showSummarySheet = true
            }
        }
        .onAppear {
            tabBarVisibility.isVisible = false
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
                    .padding(.top, DSSpacing.sm)
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

    // MARK: - Progress header

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(session.isReviewMode ? "Reviewing Question \(session.currentQuestionNumber)" : "Question \(session.currentQuestionNumber) of \(session.totalQuestions)", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(dsColors.surfaceContainerHigh)
                        .frame(height: 8)

                    Capsule()
                        .fill(dsColors.primary)
                        .frame(
                            width: geometry.size.width * CGFloat(session.currentQuestionNumber) / CGFloat(max(session.totalQuestions, 1)),
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.3), value: session.currentQuestionNumber)
                }
            }
            .frame(height: 8)
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
                let color: Color = isLastRevealed ? (session.lastWordWasCorrect == false ? dsColors.error : dsColors.success) : dsColors.textPrimary
                segment = Text(word.text)
                    .font(wordFont)
                    .foregroundColor(color)
            } else {
                let placeholder = Text("⚬ ⚬ ⚬")
                    .font(.system(size: 32))
                    .foregroundColor(dsColors.textDisabled)
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

// MARK: - Ayah Card
// MARK: - Ayah Card
private struct AyahCardView: View {
    @ObservedObject var session: TestSessionManager
    let ayahText: Text

    @Environment(\.dsColors) private var dsColors
    @Environment(\.colorScheme) private var colorScheme

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
                        .modifier(QuranTextDarkModeModifier(isDarkMode: colorScheme == .dark)) // 2. Apply dark mode invert
                        .animation(.easeInOut(duration: 0.3), value: session.lastRevealedWordId)
                        .frame(maxWidth: .infinity)
                        .padding(DSSpacing.lg)

                    Color.clear.frame(height: 1).id(bottomAnchor)
                }
            }
            .frame(maxHeight: 280)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.xl2)
                    .fill(dsColors.surfaceContainerLowest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.xl2)
                    .stroke(dsColors.outlineVariant, lineWidth: 1)
            )
            .dsElevation(DSElevation.level2)
            .padding(.horizontal, DSSpacing.xs)
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

// MARK: - Dark Mode Modifier
private struct QuranTextDarkModeModifier: ViewModifier {
    let isDarkMode: Bool

    func body(content: Content) -> some View {
        if isDarkMode {
            content
                .colorInvert()
                .hueRotation(.degrees(180))
        } else {
            content
        }
    }
}

// MARK: - Word Feedback Toast
private struct WordFeedbackToast: View {
    let feedback: WordFeedback

    @Environment(\.dsColors) private var dsColors

    private var spokenTextDisplay: String {
        feedback.spokenText.isEmpty ? "—" : feedback.spokenText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Label {
                Text("Not quite right", bundle: .module)
            } icon: {
                Image(systemName: "xmark.circle.fill")
            }
            .dsFont(DSTypography.titleSmall)
            .foregroundStyle(dsColors.onError)

            Text("You said: \(spokenTextDisplay)", bundle: .module)
                .dsFont(DSTypography.bodySmall)
                .foregroundStyle(dsColors.onError.opacity(0.9))

            HStack(spacing: DSSpacing.xxs) {
                Text("Correct:", bundle: .module)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundStyle(dsColors.onError.opacity(0.9))
                Text(feedback.correctText)
                    .dsFont(DSTypography.labelLarge)
                    .foregroundStyle(dsColors.onError)
                    .environment(\.layoutDirection, .rightToLeft)
            }
        }
        .padding(DSSpacing.smMd)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(dsColors.error)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .dsElevation(DSElevation.level3)
        .padding(.horizontal, DSSpacing.md)
    }
}

// MARK: - Question Summary View Component
struct QuestionSummaryView: View {
    @ObservedObject var session: TestSessionManager
    let onRetryQuestion: (Int) -> Void
    let onProceedToResult: () -> Void

    @Environment(\.dsColors) private var dsColors
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var showFinishConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: DSSpacing.sm) {
                    Text("Tap a skipped or unanswered question to go back and answer it.", bundle: .module)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundStyle(dsColors.textSecondary)
                        .multilineTextAlignment(layoutDirection == .rightToLeft ? .trailing : .leading)
                        .frame(maxWidth: .infinity, alignment: layoutDirection == .rightToLeft ? .trailing : .leading)
                        .padding(.horizontal, DSSpacing.xs)

                    VStack(spacing: DSSpacing.sm) {
                        ForEach(0..<session.totalQuestions, id: \.self) { index in
                            let status = session.statusForQuestion(at: index)
                            let isRetryable = status != .answered

                            Button {
                                guard isRetryable else { return }
                                onRetryQuestion(index)
                            } label: {
                                HStack {
                                    Text("Question \(index + 1)", bundle: .module)
                                        .dsFont(DSTypography.bodyLarge)
                                        .foregroundStyle(dsColors.textPrimary)

                                    Spacer()

                                    Label(
                                        title: { Text(LocalizedStringKey(status.title), bundle: .module) },
                                        icon: { Image(systemName: status.icon) }
                                    )
                                    .dsFont(DSTypography.labelMedium)
                                    .foregroundStyle(status.color)

                                    if isRetryable {
                                        Image(systemName: layoutDirection == .rightToLeft ? "chevron.left" : "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(dsColors.textTertiary)
                                    }
                                }
                                .padding(DSSpacing.smMd)
                                .background(dsColors.surfaceContainerLowest)
                                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                            }
                            .disabled(!isRetryable)
                        }
                    }
                }
                .padding(DSSpacing.md)
            }
            .background(dsColors.background.ignoresSafeArea())
            .navigationTitle(Text("Test Overview", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if session.hasSkippedQuestions {
                            showFinishConfirmation = true
                        } else {
                            onProceedToResult()
                        }
                    } label: {
                        Text("Finish", bundle: .module)
                    }
                    .bold()
                }
            }
            // MARK: - Confirmation Alert for Skipped Questions
            .alert(
                Text("Unanswered / Skipped Questions", bundle: .module, comment: "Title of the alert shown when finishing a test with skipped or unanswered questions"),
                isPresented: $showFinishConfirmation
            ) {
                Button(role: .cancel) {} label: {
                    Text("Keep Reviewing", bundle: .module, comment: "Alert action that dismisses the finish confirmation and returns to reviewing skipped questions")
                }
                Button(role: .destructive) {
                    onProceedToResult()
                } label: {
                    Text("Finish Anyway", bundle: .module, comment: "Alert action that confirms finishing the test despite skipped or unanswered questions")
                }
            } message: {
                Text("You still have skipped or unanswered questions. Are you sure you want to finish the test?", bundle: .module, comment: "Body of the alert shown when finishing a test with skipped or unanswered questions")
            }
        }
    }
}
