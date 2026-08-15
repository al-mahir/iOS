//
//  MushafView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI
import Common
import Listening
import Taahud

struct MushafView: View {
    @StateObject private var viewModel: MushafViewModel
    @ObservedObject private var fontManager = MushafFontManager.shared
    @Environment(\.dsColors) private var dsColors

    // MARK: - Onboarding State (Appears ONCE only)
    @AppStorage("hasSeenOnboardingWalkthrough") private var hasSeenOnboarding = false
    @State private var currentStep: Int = 0

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

    // Tapped-word error detail for AI correction (muallem) mode.
    @State private var tappedTaahudWord: (word: QuranWord, errors: [TajweedError])?

    private var segmentedModes: [MushafMode] {
        MushafMode.allCases.filter { $0 != .tajweedRule }
    }

    // MARK: Listening
    @ObservedObject private var listeningVM: ListeningViewModel

    // MARK: AI Correction (Taahud)
    @ObservedObject private var taahudVM: TaahudViewModel

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
        taahudVM: TaahudViewModel,
        targetAyahNumber: Int? = nil,
        onDismiss: (() -> Void)? = nil,
        onMuallemTapped: (() -> Void)? = nil,
        hideChrome: Bool = false,
        activeAyahBinding: Binding<Int?> = .constant(nil),
        activeWordKeyBinding: Binding<String?> = .constant(nil)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.listeningVM = listeningVM
        self.taahudVM = taahudVM
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

    private var isAICorrecting: Bool {
        selectedMode == .correction && taahudVM.state != .idle
    }
    
    private var taahudWordStatuses: [String: WordHighlightStatus] {
        guard selectedMode == .correction else { return [:] }
        return Dictionary(uniqueKeysWithValues: taahudVM.wordHighlights.map { key, status in
            ("\(key.sura):\(key.aya):\(key.wordIdx)", status)
        })
    }

    private var taahudWordErrorsByKey: [String: [TajweedError]] {
        guard selectedMode == .correction else { return [:] }
        return Dictionary(uniqueKeysWithValues: taahudVM.wordErrors.map { key, errors in
            ("\(key.sura):\(key.aya):\(key.wordIdx)", errors)
        })
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
            .simultaneousGesture(
                TapGesture().onEnded {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isChromeHidden.toggle()
                    }
                }
            )
            .onChange(of: viewModel.pageNumber) { _, newValue in
                viewModel.loadPage(newValue)

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

                    if selectedMode == .correction {
                        TaahudControlBar(viewModel: taahudVM, currentPage: viewModel.currentPage, allPages: viewModel.pages)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(dsColors.background)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: -2)
                            )
                            .padding(.horizontal, DSSpacing.sm)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if selectedMode == .listening {
                        AudioControlBar(viewModel: listeningVM)
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
        .animation(.easeInOut(duration: 0.3), value: selectedMode == .correction )
        .animation(.easeInOut(duration: 0.25), value: isChromeHidden)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
                        if selectedMode == .listening { isShowingSettings = true }
                    },
                    onTapMenu: {
                        if selectedMode == .listening { isShowingSettings = true }
                    }
                )
                .tooltipAnchor(1)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // MARK: - Single, bounds-aware onboarding overlay
        .overlayPreferenceValue(TooltipAnchorKey.self) { anchors in
            ZStack {
                BoundedTooltipOverlay(
                    anchors: anchors,
                    currentStep: currentStep,
                    targetStep: 1,
                    description: "Tap here to browse all 114 Surahs.",
                    buttonTitle: "Next",
                    preferredPlacement: .below,
                    onNext: advanceStep
                )
                BoundedTooltipOverlay(
                    anchors: anchors,
                    currentStep: currentStep,
                    targetStep: 2,
                    description: "Tap and hold any verse to display its Tafseer (explanation).",
                    buttonTitle: "Next",
                    preferredPlacement: .below,
                    onNext: advanceStep
                )
                ForEach(segmentedModes.compactMap { $0.tooltipStep }, id: \.self) { step in
                    BoundedTooltipOverlay(
                        anchors: anchors,
                        currentStep: currentStep,
                        targetStep: step,
                        description: segmentedModes.first(where: { $0.tooltipStep == step })?.tooltipDescription ?? "",
                        buttonTitle: step == 6 ? "Got it!" : "Next",
                        preferredPlacement: .above,
                        onNext: advanceStep
                    )
                }
            }
        }
        .onAppear {
            viewModel.reloadSettings()

            taahudVM.onCursorLeftPage = { cursor in
                navigateToPage(forSurah: cursor.sura, ayah: cursor.aya)
            }

            if !hasSeenOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentStep = 1
                }
            }
        }
        .sheet(isPresented: $isShowingPageJump) {
            PageJumpSheet(
                totalPages: viewModel.totalPages,
                currentPage: viewModel.pageNumber,
                onSubmit: { targetPage in
                    viewModel.loadPage(targetPage)
                }
            )
        }
        .sheet(isPresented: $isShowingTajweedSheet) {
            TajweedLegendSheet()
        }
        .sheet(item: Binding(
            get: { tappedTaahudWord.map(TappedWordDetail.init) },
            set: { newValue in tappedTaahudWord = newValue.map { ($0.word, $0.errors) } }
        )) { detail in
            TaahudWordErrorDetailSheet(word: detail.word, errors: detail.errors)
                .presentationDetents([.height(240), .medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Onboarding Navigation Logic

    private func advanceStep() {
        withAnimation {
            if currentStep < 6 {
                currentStep += 1
            } else {
                currentStep = 0
                hasSeenOnboarding = true
            }
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
            if let page = viewModel.pages[viewModel.pageNumber],
               let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first {
                listeningVM.activateListeningMode(
                    surahNumber: firstWord.surah,
                    surahName: SurahNameHelper.name(for: firstWord.surah),
                    startAyah: firstWord.ayah
                )
            }
        } else if previousMode == .listening {
            listeningVM.deactivateListeningMode()
        }

        if previousMode == .correction, mode != .correction, taahudVM.state != .idle {
            taahudVM.stop()
        }
    }

    // MARK: - Fixed Bottom Card

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
                    },
                    currentStep: currentStep,
                    onNextStep: advanceStep
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .leftToRight)
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

    private var currentSurahName: String {
        guard let page = viewModel.pages[viewModel.pageNumber],
              let firstWord = page.lines.first(where: { !$0.words.isEmpty })?.words.first
        else { return "" }
        return SurahNameHelper.name(for: firstWord.surah)
    }

    private var currentJuzNumber: Int {
        MockDataService.shared.getAllJuz()
            .first { ($0.pageStart...$0.pageEnd).contains(viewModel.pageNumber) }?
            .number ?? 1
    }

    // MARK: - Page Navigation Helper

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
            let fontName = fontManager.fontName(forPage: number, set: fontSet)
            let bottomInset = (isChromeHidden || hideChrome) ? 0 : MushafLayoutMetrics.bottomBarClearance

            if isTextHidden {
                QuranPracticePageView(
                    page: page,
                    fontName: fontName,
                    bottomInset: bottomInset
                )
            } else {
                MushafPageView(
                    page: page,
                    fontName: fontName,
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
                    isCurrentPage: number == viewModel.pageNumber,
                    currentStep: currentStep,
                    onNextStep: advanceStep,
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
                    },
                    taahudWordStatuses: taahudWordStatuses,
                    taahudWordErrors: taahudWordErrorsByKey,
                    onTaahudWordTapped: { word, errors in
                        tappedTaahudWord = (word, errors)
                    }
                )
            }
        } else {
            Color.clear.onAppear { viewModel.loadPageIfNeeded(number) }
        }
    }
}

// MARK: - Surah Name Helper

private enum SurahNameHelper {
    static func name(for surahNumber: Int) -> String {
        SurahNames.name(for: surahNumber)
    }
}

// MARK: - Tapped-word error detail (AI correction mode)

private struct TappedWordDetail: Identifiable {
    let word: QuranWord
    let errors: [TajweedError]
    var id: String { "\(word.surah):\(word.ayah):\(word.wordPosition)" }

    init(_ tuple: (word: QuranWord, errors: [TajweedError])) {
        self.word = tuple.word
        self.errors = tuple.errors
    }
}

// MARK: - Mode → onboarding step mapping (kept alongside the bar's own copy)

private extension MushafMode {
    var tooltipStep: Int? {
        switch self {
        case .reading:    return 3
        case .listening:  return 4
        case .correction: return 5
        case .muallem:    return 6
        default:          return nil
        }
    }
}
