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
    @State private var selectedMode: MushafMode = .listening
    @State private var isBookmarked = false // Track bookmark state here

    init(viewModel: MushafViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

            MushafFloatingActionButton {
                isShowingModeSheet = true
            }
            .padding(.trailing, DSSpacing.md)
            .padding(.bottom, MushafLayoutMetrics.bottomBarClearance + MushafLayoutMetrics.fabBottomSpacing)
        }
        .background(dsColors.background)
        .overlay(alignment: .bottom) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.error)
                    .padding(DSSpacing.sm)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DSRadius.sm))
                    .padding(.bottom, MushafLayoutMetrics.bottomBarClearance)
            }
        }
        .safeAreaInset(edge: .top) {
            MushafTopBar(
                pageNumber: viewModel.pageNumber,
                isBookmarked: isBookmarked, // Pass the state
                onTapPageNumber: { isShowingPageJump = true },
                onTapBookmark: { isBookmarked.toggle() }, // Toggle state on tap
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
            .presentationDetents([.height(520)])
            .presentationDragIndicator(.hidden)
        }
    }

    @ViewBuilder
    private func pageContent(for number: Int) -> some View {
        if let page = viewModel.pages[number] {
            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain
            MushafPageView(
                page: page,
                fontName: fontManager.fontName(forPage: number, set: fontSet),
                bottomInset: MushafLayoutMetrics.bottomBarClearance
            )
        } else {
            Color.clear
                .onAppear { viewModel.loadPageIfNeeded(number) }
        }
    }
}
