////
////  MushafView.swift
////  Reading
////
//
//import SwiftUI
//import Common
//
//struct MushafView: View {
//    @StateObject private var viewModel: MushafViewModel
//    @ObservedObject private var fontManager = MushafFontManager.shared
//    @ObservedObject private var qraaManager: QraaManager
//    @Environment(\.dsColors) private var dsColors
//
//    @State private var isShowingPageJump = false
//    @State private var isShowingModeSheet = false
//    @State private var selectedMode: MushafMode = .tajweedRule
//    @State private var isBookmarked = false
//    @State private var isPlayingAudio = false
//
//    // Speech recognition
//    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @State private var isSpeechAvailable = false
//    @State private var savedPositions: [Int: Int] = [:]
//    @State private var awaitingSurahContinuation = false
//
//    init(viewModel: MushafViewModel, qraaManager: QraaManager) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//        _qraaManager = ObservedObject(wrappedValue: qraaManager)
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            TabView(selection: $viewModel.pageNumber) {
//                ForEach(1...viewModel.totalPages, id: \.self) { number in
//                    pageContent(for: number)
//                        .tag(number)
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .environment(\.layoutDirection, .rightToLeft)
//            .onChange(of: viewModel.pageNumber) { newValue in
//                viewModel.loadPage(newValue)
//                handlePageNumberChanged()
//            }
//            .onChange(of: viewModel.currentPage?.id) { _ in
//                handleCurrentPageLoaded()
//            }
//            .onChange(of: qraaManager.pageCompleted) { completed in
//                guard completed else { return }
//                awaitingSurahContinuation = true
//                viewModel.nextPage()
//            }
//            .onChange(of: qraaManager.isSessionComplete) { done in
//                if done, speechRecognizer.isRecording {
//                    stopRecording()
//                }
//            }
//            .onChange(of: selectedMode) { newMode in
//                if [.reading, .correction, .muallem].contains(newMode) {
//                    startNewSession()
//                } else {
//                    qraaManager.updateState(mode: newMode, page: viewModel.currentPage)
//                    if speechRecognizer.isRecording {
//                        stopRecording()
//                    }
//                }
//            }
//
//            if viewModel.isLoading {
//                ProgressView()
//            }
//
//            fixedBottomCard
//        }
//        .background(dsColors.background)
//        .overlay(alignment: .bottom) {
//            if let error = viewModel.errorMessage {
//                Text(error)
//                    .dsFont(DSTypography.bodySmall)
//                    .foregroundColor(dsColors.error)
//                    .padding(DSSpacing.sm)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm))
//                    .padding(.bottom, 110)
//            }
//        }
//        .safeAreaInset(edge: .top) {
//            MushafTopBar(
//                pageNumber: viewModel.pageNumber,
//                isBookmarked: isBookmarked,
//                onTapPageNumber: { isShowingPageJump = true },
//                onTapBookmark: { isBookmarked.toggle() },
//                onTapSettings: { },
//                tajweedBinding: $viewModel.isTajweedEnabled,
//                isTajweedToggleEnabled: fontManager.isReady && fontManager.isFontSetAvailable(.plain)
//            )
//        }
//        .sheet(isPresented: $isShowingPageJump) {
//            PageJumpSheet(
//                totalPages: viewModel.totalPages,
//                currentPage: viewModel.pageNumber
//            ) { newPage in
//                viewModel.loadPage(newPage)
//            }
//            .presentationDetents([.height(220)])
//        }
//        .sheet(isPresented: $isShowingModeSheet) {
//            MushafModeSheet(selectedMode: selectedMode) { mode in
//                selectedMode = mode
//            }
//            .presentationDetents([.height(560)])
//            .presentationDragIndicator(.hidden)
//        }
//        .onAppear {
//            speechRecognizer.requestAuthorization { granted in
//                isSpeechAvailable = granted
//            }
//        }
//    }
//
//    // MARK: - Session lifecycle
//
//    private func handlePageNumberChanged() {
//        guard [.reading, .correction, .muallem].contains(selectedMode) else {
//            qraaManager.updateState(mode: selectedMode, page: viewModel.currentPage)
//            return
//        }
//
//        if awaitingSurahContinuation {
//            return
//        }
//
//        if speechRecognizer.isRecording {
//            stopRecording()
//        }
//    }
//
//    private func handleCurrentPageLoaded() {
//        guard [.reading, .correction, .muallem].contains(selectedMode) else { return }
//
//        if awaitingSurahContinuation, let page = viewModel.currentPage {
//            awaitingSurahContinuation = false
//            qraaManager.continueOnNextPage(page)
//        } else {
//            startNewSession()
//        }
//    }
//
//    private func startNewSession() {
//        guard let page = viewModel.currentPage else { return }
//        // Get all words first
//        let allWords = page.lines.flatMap(\.words)
//        // Get only reciteable words (exclude verse numbers)
//        let reciteableWords = allWords.filter { $0.wordPosition != 0 }
//
//        guard let firstWord = reciteableWords.first else {
//            print("⚠️ [View] No reciteable words found on page")
//            return
//        }
//        
//        let startWordId: Int = firstWord.id
//        let endMode: RecitationEndMode = .endOfPage
//        
//        print("🎯 [View] Starting session with first word: '\(firstWord.text)' (ID: \(firstWord.id), wordPosition: \(firstWord.wordPosition))")
//
//        qraaManager.configureSession(page: page, range: RecitationRange(startWordId: startWordId, endMode: endMode))
//    }
//    // MARK: - Fixed Dynamic Bottom Card
//
//    private var fixedBottomCard: some View {
//        HStack(spacing: DSSpacing.sm) {
//            bottomCardContent
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .frame(height: 64)
//            MushafFloatingActionButton {
//                isShowingModeSheet = true
//            }
//            .padding(.vertical, DSSpacing.md)
//        }
//        .padding(.horizontal, DSSpacing.md)
//        .padding(.vertical, DSSpacing.xs)
//        .frame(maxWidth: .infinity, minHeight: 70)
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(dsColors.background)
//                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
//        )
//        .padding(.horizontal, DSSpacing.sm)
//        .padding(.bottom, DSSpacing.xs)
//    }
//
//    @ViewBuilder
//    private var bottomCardContent: some View {
//        switch selectedMode {
//        case .tajweedRule:
//            tajweedLegendView
//        case .listening:
//            audioPlayerControlsView
//        case .reading, .correction, .muallem:
//            micRecorderView
//        }
//    }
//
//    // MARK: - Mode 1: Tajweed Color Definitions
//    private var tajweedLegendView: some View {
//        let rows = [
//            GridItem(.fixed(28), spacing: 6),
//            GridItem(.fixed(28), spacing: 6)
//        ]
//
//        return ScrollView(.horizontal, showsIndicators: false) {
//            LazyHGrid(rows: rows, spacing: 8) {
//                ForEach(TajweedRule.allCases) { rule in
//                    tajweedItem(for: rule)
//                }
//            }
//            .padding(.vertical, 2)
//        }
//    }
//
//    private func tajweedItem(for rule: TajweedRule) -> some View {
//        HStack(spacing: 6) {
//            Circle()
//                .fill(rule.color)
//                .frame(width: 8, height: 8)
//
//            Text(rule.title)
//                .font(.caption2)
//                .fontWeight(.medium)
//                .foregroundColor(dsColors.textSecondary)
//                .lineLimit(1)
//                .fixedSize(horizontal: true, vertical: false)
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 4)
//        .frame(height: 28)
//        .background(dsColors.surfaceContainerHigh, in: Capsule())
//    }
//
//    // MARK: - Mode 2: Audio Player Bar
//    private var audioPlayerControlsView: some View {
//        HStack(spacing: 16) {
//            Button(action: { isPlayingAudio.toggle() }) {
//                Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
//                    .font(.system(size: 32))
//                    .foregroundColor(dsColors.primary)
//            }
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Reciting Verse...")
//                    .font(.caption)
//                    .bold()
//                    .foregroundColor(dsColors.textPrimary)
//                ProgressView(value: 0.45)
//                    .tint(dsColors.primary)
//            }
//        }
//    }
//
//    // MARK: - Modes 3, 4, 5: Mic Record & Sound Track Toggle
//    private var micRecorderView: some View {
//        let isRecording = speechRecognizer.isRecording
//        let recordLabel = isRecording ? "Pause" : "Record"
//
//        return HStack(spacing: 12) {
//            Button(action: {
//                if isRecording {
//                    stopRecording()
//                } else {
//                    startRecording()
//                }
//            }) {
//                HStack(spacing: 8) {
//                    Image(systemName: isRecording ? "pause.circle.fill" : "mic.circle.fill")
//                        .font(.system(size: 28))
//                        .foregroundColor(isRecording ? .red : dsColors.primary)
//
//                    Text(recordLabel)
//                        .font(.subheadline)
//                        .bold()
//                        .foregroundColor(dsColors.textPrimary)
//                }
//            }
//            .disabled(!isSpeechAvailable)
//
//            if isRecording {
//                HStack(spacing: 3) {
//                    ForEach(0..<6, id: \.self) { _ in
//                        RoundedRectangle(cornerRadius: 2)
//                            .fill(dsColors.primary)
//                            .frame(width: 3, height: CGFloat.random(in: 8...24))
//                    }
//                }
//                .transition(.opacity.combined(with: .scale))
//            } else {
//                Text(isSpeechAvailable ? "Tap mic to recite" : "Speech not available")
//                    .font(.caption)
//                    .foregroundColor(dsColors.textTertiary)
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func pageContent(for number: Int) -> some View {
//        if let page = viewModel.pages[number] {
//            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain
//
//            if [.reading, .correction, .muallem].contains(selectedMode) {
//                QraaMushafPageView(
//                    page: page,
//                    fontName: fontManager.fontName(forPage: number, set: .plain),
//                    bottomInset: 85,
//                    qraaManager: qraaManager
//                )
//            } else {
//                MushafPageView(
//                    page: page,
//                    fontName: fontManager.fontName(forPage: number, set: fontSet),
//                    bottomInset: 85
//                )
//            }
//        } else {
//            Color.clear
//                .onAppear { viewModel.loadPageIfNeeded(number) }
//        }
//    }
//
//    // MARK: - Recording Methods
//
//    private func startRecording() {
//        print("🎬 [View] startRecording tapped - page=\(String(describing: viewModel.currentPage?.id)) target=\(qraaManager.activeTargetWord?.text ?? "nil")")
//        guard viewModel.currentPage != nil else { return }
//
//        speechRecognizer.stopRecording()
//        speechRecognizer.startRecording { spokenText in
//            self.processSpokenText(spokenText)
//        }
//    }
//
//    private func stopRecording() {
//        speechRecognizer.stopRecording()
//        if let page = viewModel.currentPage {
//            savedPositions[page.id] = qraaManager.lastRevealedWordId
//        }
//    }
//
//    private func processSpokenText(_ spokenText: String) {
//        print("🔊 [View] received spoken word: '\(spokenText)'")
//        guard let currentPage = viewModel.currentPage else { return }
//        guard let targetWord = qraaManager.activeTargetWord else { return }
//
//        qraaManager.lastSpokenText = spokenText
//
//        qraaManager.evaluateSpokenWord(
//            spokenText,
//            targetWord: targetWord,
//            currentPage: currentPage
//        )
//
//        if case .incorrect = qraaManager.status {
//            speechRecognizer.allowRetry()
//        }
//    }
//}
