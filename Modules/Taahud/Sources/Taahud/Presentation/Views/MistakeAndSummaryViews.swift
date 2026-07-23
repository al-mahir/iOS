import SwiftUI

/// `LabeledContent` and `NavigationStack` are iOS 16+; this module targets
/// iOS 15, so this file sticks to `NavigationView` and a small hand-rolled
/// key/value row instead.
private struct KeyValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

/// Story 8: View Mistake Details.
struct MistakeDetailView: View {
    let mistake: MistakeRecord
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section("Word") {
                    Text(mistake.word.uthmani).font(.title2)
                }
                Section("What happened") {
                    KeyValueRow(label: "Channel", value: mistake.error.errorType.rawValue)
                    KeyValueRow(label: "Type", value: mistake.error.speechErrorType.rawValue)
                    KeyValueRow(label: "Expected", value: mistake.error.expectedPh)
                    KeyValueRow(label: "Heard", value: mistake.error.predictedPh)
                    if let expectedLen = mistake.error.expectedLen, let predictedLen = mistake.error.predictedLen {
                        KeyValueRow(label: "Expected length", value: "\(expectedLen)")
                        KeyValueRow(label: "Held length", value: "\(predictedLen)")
                    }
                    if let confidence = mistake.error.confidence {
                        KeyValueRow(label: "Model confidence", value: String(format: "%.0f%%", confidence * 100))
                    } else {
                        Text("Unscored finding — shown as a hint, not counted against you.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                if !mistake.error.tajweedRules.isEmpty {
                    Section("Tajwīd rules") {
                        ForEach(mistake.error.tajweedRules, id: \.nameEn) { rule in
                            VStack(alignment: .leading) {
                                Text(rule.nameAr).font(.headline)
                                if let golden = rule.goldenLen {
                                    Text("Expected \(golden) counts").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

/// Stories 11, 12, 13.
struct SessionSummaryView: View {
    @StateObject var viewModel: TaahudSummaryViewModel

    var body: some View {
        List {
            Section("Performance") {
                KeyValueRow(label: "Accuracy", value: String(format: "%.0f%%", viewModel.summary.accuracy * 100))
                KeyValueRow(label: "Correct words", value: "\(viewModel.summary.correctWords)")
                KeyValueRow(label: "Hinted words", value: "\(viewModel.summary.hintedWords)")
                KeyValueRow(label: "Mistakes", value: "\(viewModel.summary.mistakeWords)")
            }

            Section("Mistakes to review") {
                ForEach(viewModel.summary.mistakes) { mistake in
                    Button {
                        viewModel.select(mistake)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(mistake.word.uthmani)
                            Text("\(mistake.error.errorType.rawValue) · expected \(mistake.error.expectedPh)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Suggested: āyāt to review") {
                ForEach(viewModel.ayahsToReview) { ayah in
                    Text("Sūrah \(ayah.sura):\(ayah.aya) — \(ayah.mistakeCount) mistake(s)")
                }
            }

            Section("Suggested: rules to review") {
                ForEach(viewModel.rulesToReview) { rule in
                    Text("\(rule.nameAr) — \(rule.occurrences)×")
                }
            }

            if !viewModel.frequentPatterns.isEmpty {
                Section("Frequently repeated") {
                    ForEach(viewModel.frequentPatterns, id: \.self) { pattern in
                        Text(pattern)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $viewModel.selectedMistake) { mistake in
            MistakeDetailView(mistake: mistake) { viewModel.clearSelection() }
        }
        .navigationTitle("Session Summary")
    }
}
