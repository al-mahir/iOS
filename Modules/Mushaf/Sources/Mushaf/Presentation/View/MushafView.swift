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
    @Environment(\.dsColors) private var dsColors

    // MARK: UI State
    @State private var isShowingPageJump      = false
    @State private var isShowingTajweedSheet  = false
    @State private var isShowingSettings      = false
    @State private var isShowingSearch        = false
    @State private var selectedMode: MushafMode = .reading
    @State private var isPlayingAudio         = false
    @State private var isRecording            = false
    @State private var isTextHidden           = false
    @State private var isChromeHidden         = false

    private var segmentedModes: [MushafMode] {
        MushafMode.allCases.filter { $0 != .tajweedRule }
    }

    // MARK: Listening
    @ObservedObject private var listeningVM: ListeningViewModel

    // MARK: Reading / Correction / Muallem
    @ObservedObject private var readingVM: ReadingViewModel

    private let targetAyahNumber: Int?
    private let onDismiss: (() -> Void)?
    private let onMuallemTapped: (() -> Void)?
    
    // For embedding
    private let hideChrome: Bool
    @Binding private var activeAyahBinding: Int?
    @Binding private var activeWordKeyBinding: String?

    init(
        viewModel: MushafViewModel,
        listeningVM: ListeningViewModel,
        readingVM: ReadingViewModel,
        targetAyahNumber: Int? = nil,
        onDismiss: (() -> Void)? = nil,
        onMuallemTapped: (() -> Void)? = nil,
        hideChrome: Bool = false,
        activeAyahBinding: Binding<Int?> = .constant(nil),
        activeWordKeyBinding: Binding<String?> = .constant(nil)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.listeningVM = listeningVM
        self.readingVM = readingVM
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
        self.onMuallemTapped = onMuallemTapped
        self.hideChrome = hideChrome
        self._activeAyahBinding = activeAyahBinding
        self._activeWordKeyBinding = activeWordKeyBinding
    }

    private var isListening: Bool {
        selectedMode == .listening && listeningVM.isListeningModeActive
    }

    /// True while the "Recitation" (correction) segment is selected and a
    /// live word-by-word session is running.
    private var isCorrecting: Bool {
        selectedMode == .correction && readingVM.isReadingModeActive
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
            // Tap anywhere on the page to toggle the top/bottom chrome away,
            // leaving only the Qur'an text. Simultaneous so it doesn't steal
            // the page-swipe gesture or the word long-press gesture.
            .simultaneousGesture(
                TapGesture().onEnded {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isChromeHidden.toggle()
                    }
                }
            )
            .onChange(of: viewModel.pageNumber) { _, newValue in
                viewModel.loadPage(newValue)

                if isCorrecting, let page = viewModel.pages[newValue] {
                    readingVM.deactivateReadingMode()
                    readingVM.activateReadingMode(page: page)
                }

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

            if viewModel.isLoading {
                ProgressView()
            }

           
            if !isChromeHidden && !hideChrome {
                VStack(alignment: .trailing, spacing: DSSpacing.sm) {
                    
                    MushafFloatingActionButton {
                        isShowingTajweedSheet = true
                    }
                    .padding(.trailing, DSSpacing.md)
                    .transition(.scale.combined(with: .opacity))

                    if isListening {
                        AudioControlBar(viewModel: listeningVM)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if isCorrecting {
                        ReadingControlBar(viewModel: readingVM, currentPage: viewModel.currentPage)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(dsColors.background)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: -2)
                            )
                            .padding(.horizontal, DSSpacing.sm)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    fixedBottomCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isListening)
        .animation(.easeInOut(duration: 0.3), value: isCorrecting)
        .animation(.easeInOut(duration: 0.25), value: isChromeHidden)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
        // MARK: Top Bar — hidden while the page is in focus mode or embedded
        .safeAreaInset(edge: .top) {
            if !isChromeHidden && !hideChrome {
                MushafTopBar(
                    pageNumber: viewModel.pageNumber,
                    juzNumber: currentJuzNumber,
                    surahName: currentSurahName,
                    onDismiss: onDismiss,
                    onTapNavigate: { isShowingPageJump = true },
                    onTapSearch: { isShowingSearch = true },
                    onTapSettings: {
                        if selectedMode == .listening {
                            isShowingSettings = true
                        }
                    },
                    onTapMenu: {
                        if selectedMode == .listening {
                            isShowingSettings = true
                        }
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // MARK: Sheets
        .sheet(isPresented: $isShowingPageJump) {
            PageJumpSheet(
                totalPages: viewModel.totalPages,
                currentPage: viewModel.pageNumber
            ) { newPage in
                viewModel.loadPage(newPage)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingSearch) {
            // TODO: replace with the app's actual search screen.
            Text("Search")
        }
        .sheet(isPresented: $isShowingTajweedSheet) {
            TajweedLegendSheet()
                .presentationDetents([.height(420), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingSettings) {
            ReciterSettingsSheet(viewModel: listeningVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.reloadSettings()
        }
    }

    // MARK: - Mode Handling

    private func handleModeChange(to mode: MushafMode) {
        if mode == .muallem {
            onMuallemTapped?()
            // We do not change selectedMode here, so it reverts visually.
            return
        }
        
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

        if mode == .correction {
            readingVM.activateReadingMode(page: viewModel.pages[viewModel.pageNumber])
        } else if previousMode == .correction {
            readingVM.deactivateReadingMode()
        }
    }

    // MARK: - Fixed Bottom Card (non-listening modes)

    private var fixedBottomCard: some View {
        VStack(spacing: DSSpacing.sm) {

            HStack(spacing: DSSpacing.sm) {
                MushafModeSegmentedBar(
                    selectedMode: Binding(
                        get: { selectedMode },
                        set: { handleModeChange(to: $0) }
                    ),
                    modes: segmentedModes,
                    isTextHidden: isTextHidden,
                    onToggleTextHidden: {
                        withAnimation(.easeInOut(duration: 0.2)) { isTextHidden.toggle() }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
        case .tajweedRule, .listening:
            EmptyView()
        case .reading, .correction, .muallem:
            micRecorderView
        }
    }

    // MARK: - Modes 3, 4, 5: Mic Recorder

    private var micRecorderView: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation { isRecording.toggle() }
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
                Text("Tap mic to recite")
                    .font(.caption)
                    .foregroundColor(dsColors.textTertiary)
            }
        }
    }

    // MARK: - Top Bar Helpers

    /// Surah shown on the currently visible page (based on its first word).
    private var currentSurahName: String {
        guard let page = viewModel.pages[viewModel.pageNumber],
              let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first
        else { return "" }
        return SurahNameHelper.name(for: firstWord.surah)
    }

    /// Juz' containing the currently visible page.
    private var currentJuzNumber: Int {
        MockDataService.shared.getAllJuz()
            .first { ($0.pageStart...$0.pageEnd).contains(viewModel.pageNumber) }?
            .number ?? 1
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

    // Inside MushafView.swift -> pageContent(for number: Int)

    @ViewBuilder
    private func pageContent(for number: Int) -> some View {
        if let page = viewModel.pages[number] {
            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain

            if isCorrecting {
                ReadingPageView(
                    page: page,
                    fontName: fontManager.fontName(forPage: number, set: fontSet),
                    bottomInset: (isChromeHidden || hideChrome) ? 0 : MushafLayoutMetrics.listeningBarClearance,
                    viewModel: readingVM
                )
            } else if isTextHidden {
                QuranPracticePageView(
                    page: page,
                    searchRepository: readingVM.searchRepository,
                    bottomInset: (isChromeHidden || hideChrome) ? 0 : MushafLayoutMetrics.bottomBarClearance
                )
            } else {
                MushafPageView(
                    page: page,
                    fontName: fontManager.fontName(forPage: number, set: fontSet),
                    bottomInset: (isChromeHidden || hideChrome)
                        ? 0
                        : (isListening
                            ? MushafLayoutMetrics.listeningBarClearance
                            : MushafLayoutMetrics.bottomBarClearance),
                    targetAyahNumber: activeAyahBinding ?? targetAyahNumber,
                    highlightedWordKey: activeWordKeyBinding ?? (
                        (isListening && listeningVM.isWordHighlightEnabled)
                            ? listeningVM.currentWordKey
                            : nil
                    ),
                    isSurahBookmarked: { viewModel.isSurahBookmarked($0) },
                    isAyahBookmarked: { viewModel.isAyahBookmarked(surah: $0, ayah: $1) },
                    isTajweedEnabled: viewModel.isTajweedEnabled,
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
            }
        } else {
            Color.clear
                .onAppear { viewModel.loadPageIfNeeded(number) }
        }
    }
}

// MARK: - Surah Name Helper (wraps existing SurahNames from Mushaf module)

private enum SurahNameHelper {
    static func name(for surahNumber: Int) -> String {
        SurahNames.name(for: surahNumber)
    }
}

