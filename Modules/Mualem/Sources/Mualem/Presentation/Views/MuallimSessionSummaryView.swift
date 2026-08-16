import SwiftUI
import Common

public struct MuallimSessionSummaryView: View {
    public let results: [AyahFeedbackResult]
    public let totalReps: Int
    public let onPracticeAgain: () -> Void
    public let onDone: () -> Void
    
    @Environment(\.dsColors) private var dsColors
    
    public init(results: [AyahFeedbackResult], totalReps: Int, onPracticeAgain: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.results = results
        self.totalReps = totalReps
        self.onPracticeAgain = onPracticeAgain
        self.onDone = onDone
    }
    
    private var averageAccuracy: Double {
        guard !results.isEmpty else { return 0 }
        let total = results.reduce(0.0) { $0 + $1.accuracy }
        return total / Double(results.count)
    }
    
    private var mostCommonErrorType: String {
        var counts: [RecitationErrorType: Int] = [:]
        for result in results {
            for error in result.allErrors {
                counts[error.errorType, default: 0] += 1
            }
        }
        guard let max = counts.max(by: { $0.value < $1.value }) else {
            return String(localized: "None", bundle: .module, comment: "No errors recorded")
        }
        switch max.key {
        case .tajweed: return String(localized: "Tajweed", bundle: .module, comment: "Error category Tajweed")
        case .tashkeel: return String(localized: "Tashkeel", bundle: .module, comment: "Error category Tashkeel")
        case .normal: return String(localized: "Hifz", bundle: .module, comment: "Error category Hifz")
        case .sifa: return String(localized: "Sifa", bundle: .module, comment: "Error category Sifa")
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.lg) {
                VStack(spacing: DSSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundColor(dsColors.success)
                    
                    Text("Session Complete!", bundle: .module, comment: "Summary header title")
                        .dsFont(DSTypography.headlineLarge)
                        .foregroundColor(dsColors.textPrimary)
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                    statCard(title: String(localized: "Ayahs", bundle: .module, comment: "Ayahs count label"), value: "\(results.count)")
                    statCard(title: String(localized: "Reps", bundle: .module, comment: "Repetitions count label"), value: "\(totalReps)")
                    statCard(title: String(localized: "Accuracy", bundle: .module, comment: "Accuracy percentage label"), value: "\(Int(averageAccuracy * 100))%")
                    statCard(title: String(localized: "Top Error", bundle: .module, comment: "Top error type label"), value: mostCommonErrorType)
                }
                
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Breakdown", bundle: .module, comment: "Ayah breakdown section header")
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: DSSpacing.xs) {
                            ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                                HStack {
                                    Text("Ayah \(result.aya)", bundle: .module, comment: "Ayah number tag")
                                        .dsFont(DSTypography.bodyMedium)
                                        .foregroundColor(dsColors.textPrimary)
                                        .frame(width: 60, alignment: .leading)
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(dsColors.surfaceContainerLow)
                                            Capsule().fill(colorForAccuracy(result.accuracy))
                                                .frame(width: geo.size.width * CGFloat(result.accuracy))
                                        }
                                    }
                                    .frame(height: 8)
                                    
                                    Text("\(Int(result.accuracy * 100))%")
                                        .dsFont(DSTypography.labelSmall)
                                        .foregroundColor(dsColors.textSecondary)
                                        .frame(width: 40, alignment: .trailing)
                                }
                                .padding(.vertical, DSSpacing.xxs)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
                .padding(DSSpacing.md)
                .background(dsColors.surfaceContainerLow)
                .cornerRadius(DSRadius.md)
                
                VStack(spacing: DSSpacing.sm) {
                    Button(action: onPracticeAgain) {
                        Text("Practice Again", bundle: .module, comment: "Practice again button label")
                            .dsFont(DSTypography.labelLarge)
                            .foregroundColor(dsColors.onPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(DSSpacing.md)
                            .background(dsColors.primary)
                            .cornerRadius(DSRadius.full)
                    }
                    
                    Button(action: onDone) {
                        Text("Done", bundle: .module, comment: "Done button label")
                            .dsFont(DSTypography.labelLarge)
                            .foregroundColor(dsColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(DSSpacing.md)
                            .background(dsColors.primary.opacity(0.1))
                            .cornerRadius(DSRadius.full)
                    }
                }
            }
            .padding(DSSpacing.xl)
            .background(dsColors.surface)
            .cornerRadius(DSRadius.xl)
            .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
            .padding(DSSpacing.lg)
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Text(value)
                .dsFont(DSTypography.headlineMedium)
                .foregroundColor(dsColors.primary)
            Text(title)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.sm)
    }
    
    private func colorForAccuracy(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 { return dsColors.success }
        if accuracy >= 0.7 { return dsColors.warning }
        return dsColors.error
    }
}
