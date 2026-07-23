import SwiftUI

struct TaahudSessionView: View {
    @StateObject var viewModel: TaahudSessionViewModel

    var body: some View {
        VStack(spacing: 16) {
            header

            if let warning = viewModel.engineMismatchWarning {
                Text(warning)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            wordsGrid

            Spacer()

            controls
        }
        .padding()
        .task { await viewModel.start() }
        .sheet(item: mistakeBinding) { mistake in
            MistakeDetailView(mistake: mistake) { viewModel.clearSelectedMistake() }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(statusText)
                .font(.headline)
            ProgressView(value: viewModel.runningAccuracy)
                .tint(.green)
            Text("\(Int(viewModel.runningAccuracy * 100))% so far")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var statusText: String {
        switch viewModel.phase {
        case .idle: return "Ready"
        case .requestingMicPermission: return "Requesting microphone access…"
        case .micPermissionDenied: return "Microphone access is required to start a session."
        case .connecting: return "Connecting…"
        case .active: return viewModel.localSpeechActivity == .speaking ? "Listening…" : "Waiting for recitation…"
        case .paused: return "Paused"
        case .ending: return "Finishing up…"
        case .finished: return "Session complete"
        case .failed(let message): return message
        }
    }

    /// Story 7: highlight per the three rules — hint for `almost`, neutral
    /// for `trimmed`, nothing for words that never arrived because the chunk
    /// was `ambiguous`/`no_match`.
    private var wordsGrid: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(viewModel.currentWords) { word in
                    Text(word.uthmani)
                        .padding(.horizontal, 6).padding(.vertical, 4)
                        .background(background(for: word.displayState))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onTapGesture {
                            if let firstError = word.errors.first {
                                viewModel.selectMistake(MistakeRecord(word: word, error: firstError, occurredAt: word.mushafPosition))
                            }
                        }
                }
            }
        }
    }

    private func background(for state: WordDisplayState) -> Color {
        switch state {
        case .correct: return .green.opacity(0.25)
        case .hint: return .yellow.opacity(0.25)      // almost: hint, never red
        case .mistake: return .red.opacity(0.25)
        case .unverified: return .gray.opacity(0.15)  // trimmed: neutral
        }
    }

    private var controls: some View {
        HStack(spacing: 24) {
            switch viewModel.phase {
            case .active:
                Button("Pause") { viewModel.pause() }
                Button("Finish") { viewModel.finish() }
            case .paused:
                Button("Resume") { viewModel.resume() }
                Button("Finish") { viewModel.finish() }
            default:
                EmptyView()
            }
        }
        .buttonStyle(.borderedProminent)
    }

    private var mistakeBinding: Binding<MistakeRecord?> {
        Binding(get: { viewModel.selectedMistake }, set: { _ in viewModel.clearSelectedMistake() })
    }
}
