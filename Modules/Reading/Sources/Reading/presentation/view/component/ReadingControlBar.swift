////
////  ReadingControlBar.swift
////  Reading
////
////  Created by Basmala Abuzied Ahmed on 24/07/2026.
////
//
//
//import SwiftUI
//import Mushaf
//
//public struct ReadingControlBar: View {
//    @ObservedObject var viewModel: ReadingViewModel
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var isSpeechAvailable = false
//
//    let currentPage: MushafPage?
//
//    public init(viewModel: ReadingViewModel, currentPage: MushafPage?) {
//        self.viewModel = viewModel
//        self.currentPage = currentPage
//    }
//
//    public var body: some View {
//        let isRecording = speechRecognizer.isRecording
//        let recordLabel = isRecording ? "Pause" : "Record"
//
//        HStack(spacing: 12) {
//            Button(action: {
//                if isRecording { stopRecording() } else { startRecording() }
//            }) {
//                HStack(spacing: 8) {
//                    Image(systemName: isRecording ? "pause.circle.fill" : "mic.circle.fill")
//                        .font(.system(size: 28))
//                        .foregroundColor(isRecording ? .red : .accentColor)
//                    Text(recordLabel).font(.subheadline).bold()
//                }
//            }
//            .disabled(!isSpeechAvailable)
//
//            if isRecording {
//                HStack(spacing: 3) {
//                    ForEach(0..<6, id: \.self) { _ in
//                        RoundedRectangle(cornerRadius: 2)
//                            .fill(Color.accentColor)
//                            .frame(width: 3, height: CGFloat.random(in: 8...24))
//                    }
//                }
//                .transition(.opacity.combined(with: .scale))
//            } else {
//                Text(isSpeechAvailable ? "Tap mic to recite" : "Speech not available")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .onAppear {
//            speechRecognizer.requestAuthorization { granted in
//                isSpeechAvailable = granted
//            }
//        }
//        .onChange(of: viewModel.isSessionComplete) { done in
//            if done, speechRecognizer.isRecording { stopRecording() }
//        }
//    }
//
//    private func startRecording() {
//        guard currentPage != nil else { return }
//        speechRecognizer.stopRecording()
//        speechRecognizer.startRecording { spokenText in
//            self.processSpokenText(spokenText)
//        }
//    }
//
//    private func stopRecording() {
//        speechRecognizer.stopRecording()
//    }
//
//    private func processSpokenText(_ spokenText: String) {
//        guard let currentPage else { return }
//        guard let targetWord = viewModel.activeTargetWord else { return }
//
//        viewModel.lastSpokenText = spokenText
//        viewModel.evaluateSpokenWord(spokenText, targetWord: targetWord, currentPage: currentPage)
//
//        if case .incorrect = viewModel.status {
//            speechRecognizer.allowRetry()
//        }
//    }
//}
