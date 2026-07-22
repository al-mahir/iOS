//
//  MushafView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import SwiftUI
import Common

struct MushafView: View {
    @StateObject private var viewModel: MushafViewModel
    @ObservedObject private var fontManager = MushafFontManager.shared
    @Environment(\.dsColors) private var dsColors

    @State private var isShowingPageJump = false
    @State private var isShowingModeSheet = false
    @State private var selectedMode: MushafMode = .tajweedRule
    @State private var isPlayingAudio = false
    @State private var isRecording = false
    private let targetAyahNumber: Int?
    private let onDismiss: (() -> Void)?

    init(viewModel: MushafViewModel, targetAyahNumber: Int? = nil, onDismiss: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.pageNumber) {
                ForEach(1...viewModel.totalPages, id: \.self) { number in
                    pageContent(for: number)
                        .tag(number)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environment(\.layoutDirection, .rightToLeft)
            .onChange(of: viewModel.pageNumber) { newValue in
                viewModel.loadPage(newValue)
            }

            if viewModel.isLoading {
                ProgressView()
            }

            // MARK: - Fixed Bottom Card
            fixedBottomCard
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
                onTapSettings: { },
                tajweedBinding: $viewModel.isTajweedEnabled,
                isTajweedToggleEnabled: fontManager.isReady && fontManager.isFontSetAvailable(.plain)
            )
        }
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
                selectedMode = mode
            }
            .presentationDetents([.height(560)])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Fixed Dynamic Bottom Card
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
            audioPlayerControlsView
        case .reading , .correction, .muallem:
            micRecorderView
        }
    }
    // MARK: - Mode 1: Tajweed Color Definitions
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

    // MARK: - Modes 3, 4, 5: Mic Record & Sound Track Toggle
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
                // Waveform indicator when active
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
    @ViewBuilder
    private func pageContent(for number: Int) -> some View {
        if let page = viewModel.pages[number] {
            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain
            MushafPageView(
                page: page,
                fontName: fontManager.fontName(forPage: number, set: fontSet),
                bottomInset: MushafLayoutMetrics.bottomBarClearance,
                targetAyahNumber: targetAyahNumber,
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
}

