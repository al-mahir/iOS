import SwiftUI
import Common

public struct MuallimMistakesSheet: View {
    public let feedbackResult: AyahFeedbackResult
    public let onContinue: () -> Void
    
    @Environment(\.dsColors) private var dsColors
    
    public init(feedbackResult: AyahFeedbackResult, onContinue: @escaping () -> Void) {
        self.feedbackResult = feedbackResult
        self.onContinue = onContinue
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: DSSpacing.md) {
                    ayahTextView
                    
                    if !feedbackResult.nonVerse.isEmpty {
                        nonVerseView
                    }
                    
                    wordListView
                }
                .padding(DSSpacing.md)
            }
            
            bottomBar
        }
        .background(dsColors.background.ignoresSafeArea())
        .presentationDetents([.medium, .large])
    }
    
    private var headerView: some View {
        HStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .stroke(dsColors.outlineVariant, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(feedbackResult.accuracy))
                    .stroke(dsColors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(feedbackResult.accuracy * 100))%")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textPrimary)
            }
            .frame(width: 48, height: 48)
            
            Spacer()
            
            HStack(spacing: DSSpacing.sm) {
                countBadge(icon: "checkmark.circle.fill", count: feedbackResult.correctCount, color: dsColors.success)
                countBadge(icon: "exclamationmark.triangle.fill", count: feedbackResult.hintCount, color: dsColors.warning)
                countBadge(icon: "xmark.circle.fill", count: feedbackResult.errorCount, color: dsColors.error)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
    
    private func countBadge(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textPrimary)
        }
    }
    
    private var ayahTextView: some View {
        var combinedText = Text("")
        for (index, word) in feedbackResult.words.enumerated() {
            let space = index == feedbackResult.words.count - 1 ? "" : " "
            var color = dsColors.textPrimary
            switch word.displayStatus {
            case .correct: color = dsColors.success
            case .hint: color = dsColors.warning
            case .error: color = dsColors.error
            case .neutral: color = dsColors.textHint
            }
            
            combinedText = combinedText + Text(word.uthmani + space)
                .font(DSTypography.bodyLarge.arabicFont())
                .foregroundColor(color)
        }
        return combinedText
            .multilineTextAlignment(.trailing)
            .environment(\.layoutDirection, .rightToLeft)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(DSSpacing.sm)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.sm)
    }
    
    private var nonVerseView: some View {
        HStack {
            Image(systemName: "info.circle.fill")
            Text("\(feedbackResult.nonVerse.joined(separator: ", ")) recognized", bundle: .module, comment: "Recognized non-verse phrase notification")
                .dsFont(DSTypography.labelSmall)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .foregroundColor(dsColors.info)
        .background(dsColors.info.opacity(0.1))
        .cornerRadius(DSRadius.full)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var wordListView: some View {
        VStack(spacing: DSSpacing.sm) {
            if feedbackResult.scoredCount == 0 {
                VStack(spacing: DSSpacing.xs) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "mic.slash.fill")
                            .foregroundColor(dsColors.warning)
                        Text("No Recitation Detected", bundle: .module, comment: "Title when no voice was recognized")
                            .dsFont(DSTypography.titleSmall)
                            .foregroundColor(dsColors.textPrimary)
                    }
                    Text("The AI model didn't hear clear recitation for this Ayah. Please tap Continue and try speaking clearly into your microphone.", bundle: .module, comment: "Instruction when recitation is missing")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(DSSpacing.md)
                .frame(maxWidth: .infinity)
                .background(dsColors.warning.opacity(0.1))
                .cornerRadius(DSRadius.md)
            }
            
            ForEach(feedbackResult.words) { word in
                WordFeedbackRow(word: word)
            }
        }
    }
    
    private var bottomBar: some View {
        Button(action: onContinue) {
            Text("Continue", bundle: .module, comment: "Button to continue after mistakes sheet")
                .dsFont(DSTypography.labelLarge)
                .foregroundColor(dsColors.surface)
                .frame(maxWidth: .infinity)
                .padding(DSSpacing.md)
                .background(dsColors.primary)
                .cornerRadius(DSRadius.full)
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: -2)
    }
}

private struct WordFeedbackRow: View {
    let word: WordFeedback
    @Environment(\.dsColors) private var dsColors
    @State private var isExpanded: Bool
    
    init(word: WordFeedback) {
        self.word = word
        _isExpanded = State(initialValue: word.displayStatus == .error)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: DSSpacing.sm) {
                    statusIcon
                    Text(word.uthmani)
                        .dsArabicFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                    Spacer()
                    statusChip
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(dsColors.textSecondary)
                }
                .padding(DSSpacing.sm)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    if word.displayStatus == .hint {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            Text("Model uncertain — this may be correct", bundle: .module, comment: "Hint display status note")
                        }
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.warning)
                        .padding(.vertical, DSSpacing.xs)
                    } else if word.displayStatus == .neutral {
                        Text("Not scored (chunk boundary)", bundle: .module, comment: "Neutral display status note")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textHint)
                            .padding(.vertical, DSSpacing.xs)
                    } else {
                        ForEach(word.errors) { error in
                            WordErrorDetailView(error: error)
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.bottom, DSSpacing.sm)
            }
        }
        .background(dsColors.surface)
        .cornerRadius(DSRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .stroke(dsColors.outlineVariant, lineWidth: 1)
        )
    }
    
    private var statusIcon: some View {
        switch word.displayStatus {
        case .correct: return Image(systemName: "checkmark.circle.fill").foregroundColor(dsColors.success)
        case .hint: return Image(systemName: "exclamationmark.triangle.fill").foregroundColor(dsColors.warning)
        case .error: return Image(systemName: "xmark.circle.fill").foregroundColor(dsColors.error)
        case .neutral: return Image(systemName: "minus.circle").foregroundColor(dsColors.textHint)
        }
    }
    
    private var statusChip: some View {
        let title: String
        let color: Color
        switch word.displayStatus {
        case .correct: title = String(localized: "Correct", bundle: .module, comment: "Status chip correct"); color = dsColors.success
        case .hint: title = String(localized: "Almost", bundle: .module, comment: "Status chip almost"); color = dsColors.warning
        case .error: title = String(localized: "Error", bundle: .module, comment: "Status chip error"); color = dsColors.error
        case .neutral: title = String(localized: "Trimmed", bundle: .module, comment: "Status chip trimmed"); color = dsColors.textHint
        }
        return Text(title)
            .dsFont(DSTypography.labelSmall)
            .foregroundColor(color)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(color.opacity(0.1))
            .cornerRadius(DSRadius.full)
    }
}

private struct WordErrorDetailView: View {
    let error: WordError
    @Environment(\.dsColors) private var dsColors
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                errorTypeChip
                Spacer()
                if case .known(let conf) = error.confidence {
                    Text("Confidence: \(Int(conf * 100))%", bundle: .module, comment: "Confidence percentage label")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.textSecondary)
                }
            }
            
            Text(error.localizedDescription)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
            
            if error.errorType == .tajweed, let rule = error.tajweedRules.first {
                HStack {
                    Text(rule.nameAr)
                        .dsArabicFont(DSTypography.bodySmall)
                    Text("•")
                    Text(rule.nameEn)
                        .dsFont(DSTypography.bodySmall)
                }
                .foregroundColor(dsColors.textSecondary)
                
                if let golden = rule.goldenLen, let predicted = error.predictedLen {
                    Text("Expected \(golden), you held \(predicted)", bundle: .module, comment: "Madd/duration error message comparison")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.error)
                }
            }
        }
        .padding(DSSpacing.sm)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.sm)
    }
    
    private var errorTypeChip: some View {
        let title: String
        let color: Color
        switch error.errorType {
        case .tajweed: title = String(localized: "Tajweed", bundle: .module, comment: "Error category Tajweed"); color = dsColors.info
        case .tashkeel: title = String(localized: "Tashkeel", bundle: .module, comment: "Error category Tashkeel"); color = dsColors.warning
        case .normal: title = String(localized: "Hifz", bundle: .module, comment: "Error category Hifz"); color = dsColors.error
        case .sifa: title = String(localized: "Sifa", bundle: .module, comment: "Error category Sifa"); color = dsColors.primary
        }
        return Text(title)
            .dsFont(DSTypography.labelSmall)
            .foregroundColor(color)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(DSRadius.xs)
    }
}
