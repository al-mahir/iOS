//
//  ReadingControlBar.swift
//  Reading
//
//  Created by Basmala Abuzied Ahmed on 24/07/2026.
//

import SwiftUI

struct ReadingControlBar: View {
    @ObservedObject var viewModel: ReadingViewModel

    let currentPage: MushafPage?

    public init(viewModel: ReadingViewModel, currentPage: MushafPage?) {
        self.viewModel = viewModel
        self.currentPage = currentPage
    }

    public var body: some View {
        let isRecording = viewModel.speechRecognizer.isRecording
        let recordLabel = isRecording ? "Pause" : "Record"

        HStack(spacing: 12) {
            Button(action: {
                if isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording(currentPage: currentPage)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isRecording ? "pause.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(isRecording ? .red : .accentColor)
                    Text(recordLabel).font(.subheadline).bold()
                }
            }
            .disabled(!viewModel.isSpeechAvailable)

            if isRecording {
                HStack(spacing: 3) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentColor)
                            .frame(width: 3, height: CGFloat.random(in: 8...24))
                    }
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                Text(viewModel.isSpeechAvailable ? "Tap mic to recite" : "Speech not available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            viewModel.requestSpeechAuthorization()
        }
        .onChange(of: viewModel.isSessionComplete) { done in
            if done, viewModel.speechRecognizer.isRecording {
                viewModel.stopRecording()
            }
        }
    }
}
