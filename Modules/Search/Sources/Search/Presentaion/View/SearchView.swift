//
//  SearchView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Mushaf
import Common

public struct SearchView: View {
    @StateObject private var viewModel = DIContainer.shared.resolve(SearchViewModel.self)

    public init() {}

    public var body: some View {
        QuranSearchScreen(viewModel: viewModel)
    }
}

struct QuranSearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dsColors) var dsColors
    @Environment(\.dismiss) var dismiss

    @State private var showWordFilterSheet    = false
    @State private var showSemanticFilterSheet = false

    var body: some View {
        ZStack {
            dsColors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.md) {
                searchHeaderBar
                categorySegmentedControl

                filterTriggerRow

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {
                        if viewModel.isFetchingTafsir {
                            tafsirLoadingOverlay
                        } else if viewModel.isSearching {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                                .tint(dsColors.primary)
                        } else if viewModel.searchQuery.isEmpty {
                            defaultStateView
                        } else {
                            if viewModel.isCurrentCategoryEmpty {
                                emptyStateView
                            } else {
                                contentView
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .sheet(isPresented: $showWordFilterSheet) {
            WordFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSemanticFilterSheet) {
            SemanticFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Permission Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant microphone and speech recognition permissions in Settings.")
        }
        .onDisappear {
            if !viewModel.navigateToTafsirDetail && !viewModel.navigateToMushaf {
                viewModel.clearSearch()
                viewModel.clearFilters()
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToMushaf) {
            MushafRootView(
                startPage: viewModel.selectedPageNumber ?? 1,
                targetAyahNumber: viewModel.selectedAyahNumber,
                showBackButton: true
            )
        }
        .navigationDestination(isPresented: $viewModel.navigateToTafsirDetail) {
            if let tafsirData = viewModel.tafsirData {
                let surah = viewModel.allSurahs.first(where: { $0.id == tafsirData.surah })
                TafsirDetailView(
                    tafsirData: tafsirData,
                    surahName: surah?.englishName ?? "Surah \(tafsirData.surah)",
                    arabicName: surah?.arabicName ?? "سورة \(tafsirData.surah)"
                )
            }
        }
    }

    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }

    // MARK: – Tafsir loading overlay

    private var tafsirLoadingOverlay: some View {
        VStack(spacing: DSSpacing.md) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(dsColors.primary)

            Text("Fetching Tafsir…")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedCategory {
        case .word:
            WordSearchResultsView(viewModel: viewModel)
        case .semantic:
            semanticResultsView
        case .tafsir:
            TafsirSearchResultsView(viewModel: viewModel)
        }
    }

    // MARK: – Semantic results
    private var semanticResultsView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Results for '\(viewModel.searchQuery)'")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)

            ForEach(viewModel.searchResults, id: \.ayah.number) { result in
                AppAyahCard(
                    arabicText: result.ayah.arabicText,
                    englishTranslation: result.ayah.englishTranslation,
                    surahName: result.surah.englishName,
                    surahNumber: result.surah.id,
                    ayahNumber: result.ayah.number,
                    pageNumber: result.pageNumber
                ) {
                    viewModel.navigateToAyah(result)
                }
            }
        }
    }

    // MARK: – Filter trigger row (Word + Semantic tabs only)
    @ViewBuilder
    private var filterTriggerRow: some View {
        if viewModel.selectedCategory == .word || viewModel.selectedCategory == .semantic {
            HStack {
                if viewModel.hasActiveFilters {
                    Button(action: { viewModel.clearFilters() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Clear Filters")
                        }
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.error)
                    }
                }
                Spacer()
                Button(action: {
                    if viewModel.selectedCategory == .word     { showWordFilterSheet    = true }
                    if viewModel.selectedCategory == .semantic { showSemanticFilterSheet = true }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text(viewModel.hasActiveFilters ? "Filters Active" : "Filter Search")
                    }
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.primary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(dsColors.surfaceContainer)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(dsColors.outlineVariant, lineWidth: 1))
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}

