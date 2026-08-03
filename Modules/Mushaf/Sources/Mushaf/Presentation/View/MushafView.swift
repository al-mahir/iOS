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

    // MARK: - Onboarding State (Appears ONCE only)
    @AppStorage("hasSeenOnboardingWalkthrough") private var hasSeenOnboarding = false
    @State private var currentStep: Int = 0 // 0 means inactive / finished

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

    init(
        viewModel: MushafViewModel,
        listeningVM: ListeningViewModel,
        readingVM: ReadingViewModel,
        targetAyahNumber: Int? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.listeningVM = listeningVM
        self.readingVM = readingVM
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
    }

    private var isListening: Bool {
        selectedMode == .listening && listeningVM.isListeningModeActive
    }

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

            if !isChromeHidden {
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
        .background(dsColors.background)
        .safeAreaInset(edge: .top) {
            if !isChromeHidden {
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

            if !hasSeenOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentStep = 1
                }
            }
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

    private func handleModeChange(to mode: MushafMode) {
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

        if mode == .correction {
            readingVM.activateReadingMode(page: viewModel.pages[viewModel.pageNumber])
        } else if previousMode == .correction {
            readingVM.deactivateReadingMode()
        }
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

            MushafPageView(
                page: page,
                fontName: fontManager.fontName(forPage: number, set: fontSet),
                bottomInset: isChromeHidden ? 0 : MushafLayoutMetrics.bottomBarClearance,
                targetAyahNumber: targetAyahNumber,
                isTajweedEnabled: viewModel.isTajweedEnabled,
                isCurrentPage: number == viewModel.pageNumber,
                currentStep: currentStep,
                onNextStep: advanceStep
            )
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
