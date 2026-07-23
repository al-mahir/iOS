//
//  MushafView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI
import Common
import Listening

struct MushafView: View {
    @StateObject private var viewModel: MushafViewModel
    @ObservedObject private var fontManager = MushafFontManager.shared
    @ObservedObject private var qraaManager: QraaManager
    @Environment(\.dsColors) private var dsColors
    
    @State private var isShowingPageJump    = false
    @State private var isShowingModeSheet   = false
    @State private var isShowingSettings    = false
    @State private var selectedMode: MushafMode = .tajweedRule
    @State private var isBookmarked = false
    @State private var isPlayingAudio = false
    @State private var isRecording = false
    
    // Speech recognition
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isSpeechAvailable = false
    
//     init(viewModel: MushafViewModel, qraaManager: QraaManager) {
//         _viewModel = StateObject(wrappedValue: viewModel)
//         _qraaManager = ObservedObject(wrappedValue: qraaManager)


    @ObservedObject private var listeningVM: ListeningViewModel

    private let targetAyahNumber: Int?
    private let onDismiss: (() -> Void)?

    init(
        viewModel: MushafViewModel,
        listeningVM: ListeningViewModel,
        targetAyahNumber: Int? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.listeningVM = listeningVM
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
    }

    private var isListening: Bool {
        selectedMode == .listening && listeningVM.isListeningModeActive

    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Page Tabs
            TabView(selection: $viewModel.pageNumber) {
                ForEach(1...viewModel.totalPages, id: \.self) { number in
                    pageContent(for: number)
                        .tag(number)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environment(\.layoutDirection, .rightToLeft)
            .onChange(of: viewModel.pageNumber) { _, newValue in
                viewModel.loadPage(newValue)

                qraaManager.updateState(
                    mode: selectedMode,
                    page: viewModel.currentPage
                )


                guard isListening,
                      let page = viewModel.pages[newValue],
                      let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first
                else { return }

                let newSurah = firstWord.surah
                let newAyah  = firstWord.ayah

                if newSurah == listeningVM.currentChapterNumber {
                    // Same surah — seek audio to the first ayah on the new page instantly
                    listeningVM.seekToAyah(surah: newSurah, ayah: newAyah)
                } else {
                    // Different surah — reload the whole session for the new chapter
                    listeningVM.activateListeningMode(
                        surahNumber: newSurah,
                        surahName: SurahNameHelper.name(for: newSurah),
                        startAyah: newAyah
                    )
                }

            }
            .onChange(of: qraaManager.status) { newStatus in
                print("🔄 Status changed to: \(newStatus)")
            }
            .onChange(of: selectedMode) { newMode in
                // Update QraaManager when mode changes
                qraaManager.updateState(
                    mode: newMode,
                    page: viewModel.currentPage
                )
                // Reset recording state when leaving reading/correction/muallem modes
                if ![.reading, .correction, .muallem].contains(newMode) {
                    if isRecording {
                        stopRecording()
                    }
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            // MARK: - Fixed Bottom Card
//             fixedBottomCard

            // MARK: Bottom Area
            if isListening {
                // Listening Mode: full audio control bar, no other UI
                AudioControlBar(viewModel: listeningVM)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Normal Mode: fixed bottom card + FAB
                fixedBottomCard
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isListening)
        // MARK: Navigation on explicit audio seek
        .onChange(of: listeningVM.navigationRequestId) { _, _ in
            guard isListening else { return }
            let target = listeningVM.navigationTarget()
            navigateToPage(forSurah: target.surah, ayah: target.ayah)
        }
        .background(dsColors.background)
        .overlay(alignment: .bottom) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.error)
                    .padding(DSSpacing.sm)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm))
                    .padding(.bottom, 110)
            }
        }
        // MARK: Top Bar — always visible
        .safeAreaInset(edge: .top) {
            MushafTopBar(
                pageNumber: viewModel.pageNumber,
                isBookmarked: viewModel.isCurrentPageBookmarked,
                onDismiss: onDismiss,
                onTapPageNumber: { isShowingPageJump = true },
                onTapBookmark: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.toggleBookmarkForCurrentPage()
                },
                onTapSettings: {
                    // Settings sheet is only available in Listening Mode
                    if isListening {
                        isShowingSettings = true
                    }
                },
                tajweedBinding: $viewModel.isTajweedEnabled,
                isTajweedToggleEnabled: fontManager.isReady && fontManager.isFontSetAvailable(.plain)
            )
        }
        // MARK: Sheets
        .sheet(isPresented: $isShowingPageJump) {
            PageJumpSheet(
                totalPages: viewModel.totalPages,
                currentPage: viewModel.pageNumber
            ) { newPage in
                viewModel.loadPage(newPage)
            }
            .presentationDetents([.height(220)])
        }
        .sheet(isPresented: $isShowingModeSheet) {
            MushafModeSheet(selectedMode: selectedMode) { mode in
                handleModeChange(to: mode)
            }
            .presentationDetents([.height(560)])
            .presentationDragIndicator(.hidden)
        }
//         .onAppear {
//             // Initialize speech recognition
//             speechRecognizer.requestAuthorization { granted in
//                 isSpeechAvailable = granted
//             }
//         }
//     }
    
    // MARK: - Fixed Dynamic Bottom Card
        .sheet(isPresented: $isShowingSettings) {
            ReciterSettingsSheet(viewModel: listeningVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Mode Handling

    private func handleModeChange(to mode: MushafMode) {
        let previousMode = selectedMode
        selectedMode = mode

        if mode == .listening {
            // Start from the first ayah visible on the current page
            if let page = viewModel.pages[viewModel.pageNumber],
               let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first {
                listeningVM.activateListeningMode(
                    surahNumber: firstWord.surah,
                    surahName: SurahNameHelper.name(for: firstWord.surah),
                    startAyah: firstWord.ayah          // ← page-aware start position
                )
            }
        } else if previousMode == .listening {
            listeningVM.deactivateListeningMode()
        }
    }

    // MARK: - Fixed Bottom Card (non-listening modes)

    private var fixedBottomCard: some View {
        HStack(spacing: DSSpacing.sm) {
            bottomCardContent
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 64)
            MushafFloatingActionButton {
                isShowingModeSheet = true
            }
            .padding(.vertical, DSSpacing.md)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.xs)
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(dsColors.background)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
        )
        .padding(.horizontal, DSSpacing.sm)
        .padding(.bottom, DSSpacing.xs)
    }
    
    @ViewBuilder
    private var bottomCardContent: some View {
        switch selectedMode {
        case .tajweedRule:
            tajweedLegendView
        case .listening:
//             audioPlayerControlsView
            // Handled by AudioControlBar above; show placeholder if not yet activated
            Text("Activating listening mode…")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textTertiary)
        case .reading, .correction, .muallem:
            micRecorderView
        }
    }
  
    private var tajweedLegendView: some View {
        let rows = [
            GridItem(.fixed(28), spacing: 6),
            GridItem(.fixed(28), spacing: 6)
        ]
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(TajweedRule.allCases) { rule in
                    tajweedItem(for: rule)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private func tajweedItem(for rule: TajweedRule) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(rule.color)
                .frame(width: 8, height: 8)
            Text(rule.title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(dsColors.textSecondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .frame(height: 28)
        .background(dsColors.surfaceContainerHigh, in: Capsule())
    }

    // MARK: - Mode 2: Audio Player Bar
    private var audioPlayerControlsView: some View {
        HStack(spacing: 16) {
            Button(action: { isPlayingAudio.toggle() }) {
                Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(dsColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Reciting Verse...")
                    .font(.caption)
                    .bold()
                    .foregroundColor(dsColors.textPrimary)
                ProgressView(value: 0.45)
                    .tint(dsColors.primary)
            }
        }
    }

    private var micRecorderView: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    isRecording.toggle()
                    if isRecording {
                        startRecording()
                    } else {
                        stopRecording()
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(isRecording ? .red : dsColors.primary)
                    Text(isRecording ? "Stop" : "Record")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(dsColors.textPrimary)
                }
            }
//             .disabled(!isSpeechAvailable)
            
            if isRecording {
                HStack(spacing: 3) {
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(dsColors.primary)
                            .frame(width: 3, height: CGFloat.random(in: 8...24))
                    }
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                Text(isSpeechAvailable ? "Tap mic to recite" : "Speech not available")
                    .font(.caption)
                    .foregroundColor(dsColors.textTertiary)
            }
        }
    }

    // MARK: - Page Navigation Helper

    /// Searches all loaded pages for one containing `surah:ayah`, then navigates to it.
    /// Called only on explicit user seeks (skip, slider drag, prev/next ayah).
    private func navigateToPage(forSurah surah: Int, ayah: Int) {
        for (pageNum, page) in viewModel.pages {
            let containsWord = page.lines.contains { line in
                line.words.contains { $0.surah == surah && $0.ayah == ayah }
            }
            if containsWord, pageNum != viewModel.pageNumber {
                withAnimation(.easeInOut(duration: 0.35)) {
                    viewModel.loadPage(pageNum)
                }
                return
            }
        }
    }

    // MARK: - Page Content

    @ViewBuilder
    private func pageContent(for number: Int) -> some View {
        if let page = viewModel.pages[number] {
            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain
            
            // Use QraaMushafPageView for reading/correction/muallem modes
//             if [.reading, .correction, .muallem].contains(selectedMode) {
//                 QraaMushafPageView(
//                     page: page,
//                     fontName: fontManager.fontName(forPage: number, set: .plain),
//                     bottomInset: 85,
//                     qraaManager: qraaManager
//                 )
//             } else {
//                 MushafPageView(
//                     page: page,
//                     fontName: fontManager.fontName(forPage: number, set: fontSet),
//                     bottomInset: 85
//                 )
//             }
            MushafPageView(
                page: page,
                fontName: fontManager.fontName(forPage: number, set: fontSet),
                bottomInset: isListening
                    ? MushafLayoutMetrics.listeningBarClearance
                    : MushafLayoutMetrics.bottomBarClearance,
                targetAyahNumber: targetAyahNumber,
                highlightedWordKey: (isListening && listeningVM.isWordHighlightEnabled)
                    ? listeningVM.currentWordKey
                    : nil,
                isSurahBookmarked: { viewModel.isSurahBookmarked($0) },
                isAyahBookmarked: { viewModel.isAyahBookmarked(surah: $0, ayah: $1) },
                onBookmarkSurah: { surahNumber in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.toggleBookmarkForSurah(surahNumber: surahNumber)
                },
                onBookmarkAyah: { surah, ayah, arabicText, surahName in
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    viewModel.toggleBookmarkForAyah(
                        surahNumber: surah,
                        ayahNumber: ayah,
                        arabicText: arabicText,
                        surahName: surahName
                    )
                }
            )
        } else {
            Color.clear
                .onAppear { viewModel.loadPageIfNeeded(number) }
        }
    }
    
    // MARK: - Recording Methods
    private func startRecording() {
        guard let currentPage = viewModel.currentPage else { return }
        
        // Reset QraaManager state for new recording session
        qraaManager.updateState(mode: selectedMode, page: currentPage)
        
        // Reset speech recognizer state
        speechRecognizer.stopRecording()
        
        speechRecognizer.startRecording { spokenText in
            // Process the spoken text
            self.processSpokenText(spokenText)
        }
    }
    
    private func stopRecording() {
        speechRecognizer.stopRecording()
    }
    
    private func processSpokenText(_ spokenText: String) {
        print("🔊 Received spoken text: \(spokenText)")
        
        guard let currentPage = viewModel.currentPage else {
            print("❌ No current page")
            return
        }
        
        guard let targetWord = qraaManager.activeTargetWord else {
            print("❌ No target word")
            return
        }
        
        print("🎯 Target word: \(targetWord.text)")
        
        // Update the spoken text display
        qraaManager.lastSpokenText = spokenText
        
        // Evaluate the spoken word
        qraaManager.evaluateSpokenWord(
            spokenText,
            targetWord: targetWord,
            currentPage: currentPage
        )
        
        // If the answer was wrong, allow retry
        if case .incorrect = qraaManager.status {
            print("❌ Wrong answer, allowing retry")
            speechRecognizer.allowRetry()
        } else if case .correct = qraaManager.status {
            print("✅ Correct answer!")
        }
    }}
}

// MARK: - Surah Name Helper (wraps existing SurahNames from Mushaf module)

private enum SurahNameHelper {
    static func name(for surahNumber: Int) -> String {
        SurahNames.name(for: surahNumber)
    }
}
