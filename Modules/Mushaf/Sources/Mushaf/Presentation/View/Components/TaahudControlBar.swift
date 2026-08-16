//
//  TaahudControlBar.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 05/08/2026.
//

import SwiftUI
import Common
import Taahud

struct TaahudControlBar: View {
    @ObservedObject var viewModel: TaahudViewModel
    let currentPage: MushafPage?
    let allPages: [Int: MushafPage]

    @State private var isShowingErrorSheet = false

    var body: some View {
        let isActive = viewModel.state != .idle
        let recordLabel = isActive ? String(localized: "Stop") : String(localized: "Recite")

        HStack(spacing: 12) {
            Button(action: onMicTapped) {
                HStack(spacing: 8) {
                    Image(systemName: isActive ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(isActive ? .red : .accentColor)
                    Text(recordLabel).font(.subheadline).bold()
                }
            }
            .disabled(currentPage == nil && !isActive)

            statusArea

            Spacer()

            // MARK: - Always Visible Error Badge (Active & Inactive Modes)
            if viewModel.hardErrorCount > 0 {
                Button {
                    isShowingErrorSheet = true
                } label: {
                    Label("\(viewModel.hardErrorCount)", systemImage: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.red)
                }
                .disabled(allFlaggedWords.isEmpty)
            }
        }
        .sheet(isPresented: $isShowingErrorSheet) {
            TaahudWordErrorListSheet(
                flaggedWords: allFlaggedWords,
                onClearAll: {
                    viewModel.clearErrors()
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var statusArea: some View {
        switch viewModel.state {
        case .connecting:
            Label(String(localized: "Connecting…"), systemImage: "antenna.radiowaves.left.and.right")
                .font(.caption)
                .foregroundColor(.secondary)
        case .recording, .feedbackReceived:
            waveformBars
        case .idle:
            Text("Tap mic to recite — AI Tajweed correction")
                .font(.caption)
                .foregroundColor(.secondary)
        case .error(let message):
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
                .lineLimit(2)
        }
    }

    private var waveformBars: some View {
        HStack(spacing: 3) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: 3, height: CGFloat.random(in: 8...24))
            }
        }
        .transition(.opacity.combined(with: .scale))
    }

    private var allFlaggedWords: [(word: QuranWord, errors: [TajweedError])] {
        let errorKeys = viewModel.wordHighlights.filter { $0.value == .error }.keys

        guard !errorKeys.isEmpty else { return [] }

        var wordsByKey: [RecitationWordKey: QuranWord] = [:]
        for page in allPages.values {
            for line in page.lines {
                for word in line.words {
                    let key = RecitationWordKey(sura: word.surah, aya: word.ayah, wordIdx: word.wordPosition)
                    wordsByKey[key] = word
                }
            }
        }

        return errorKeys
            .sorted { ($0.sura, $0.aya, $0.wordIdx) < ($1.sura, $1.aya, $1.wordIdx) }
            .compactMap { key in
                guard let word = wordsByKey[key] else { return nil }
                return (word, viewModel.wordErrors[key] ?? [])
            }
    }

    private func onMicTapped() {
        switch viewModel.state {
        case .idle, .error:
            guard
                let page = currentPage,
                let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first
            else { return }
            viewModel.startSession(sura: firstWord.surah, aya: firstWord.ayah, wordIdx: firstWord.wordPosition)
        case .connecting, .recording, .feedbackReceived:
            viewModel.stop()
        }
    }
}
