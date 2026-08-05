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

    var body: some View {
        let isActive = viewModel.state != .idle
        let recordLabel = isActive ? "Stop" : "Recite"

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
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .error = newState {
                // Surface engine faults the same way a dropped mic session
                // would — stop cleanly rather than leaving a half-open socket.
                viewModel.stop()
            }
        }
    }

    @ViewBuilder
    private var statusArea: some View {
        switch viewModel.state {
        case .connecting:
            Label("Connecting…", systemImage: "antenna.radiowaves.left.and.right")
                .font(.caption)
                .foregroundColor(.secondary)
        case .recording, .feedbackReceived:
            HStack(spacing: 8) {
                waveformBars
                if viewModel.hardErrorCount > 0 {
                    Label("\(viewModel.hardErrorCount)", systemImage: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.red)
                }
            }
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
