//
//  QuranSearchScreen+defaultStateView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common

extension QuranSearchScreen {

    // MARK: – Default (empty query) state
    @ViewBuilder
    var defaultStateView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Recent searches for current category
            if !viewModel.currentCategoryHistory.isEmpty {
                recentSearchesSection
            }

            // Tab-specific initial states
            if viewModel.selectedCategory == .word {
                wordDefaultBrowse
            } else if viewModel.selectedCategory == .semantic {
                SemanticInitialStateView(viewModel: viewModel)
            } else if viewModel.selectedCategory == .tafsir {
                TafsirPlaceholderView()
            }
        }
    }

    // MARK: – Recent searches chips
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Recent Searches")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
                Button("Clear All") { viewModel.clearSearchHistory() }
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.error)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.xs) {
                    ForEach(viewModel.currentCategoryHistory) { history in
                        HStack(spacing: DSSpacing.sm) {
                            Text(history.query)
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textPrimary)
                            Button(action: { viewModel.deleteFromHistory(history) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(dsColors.textSecondary)
                            }
                        }
                        .padding(.vertical, DSSpacing.sm)
                        .padding(.horizontal, DSSpacing.smMd)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.lg)
                                .fill(dsColors.surfaceContainerHigh)
                        )
                        .onTapGesture { viewModel.searchQuery = history.query }
                    }
                }
            }
            Divider().background(dsColors.divider)
        }
    }

    // MARK: – Word tab: browse all surahs
    private var wordDefaultBrowse: some View {
        let surahsToDisplay = viewModel.selectedSurahIds.isEmpty
            ? viewModel.allSurahs
            : viewModel.allSurahs.filter { viewModel.selectedSurahIds.contains($0.id) }

        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dsColors.primary)
                Text(viewModel.selectedSurahIds.isEmpty ? "Browse All Surahs" : "Filtered Surahs")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
                Text("\(surahsToDisplay.count)")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(.horizontal, DSSpacing.xs)

            ForEach(surahsToDisplay, id: \.id) { surah in
                AppSurahCard(
                    surahNumber: surah.id,
                    arabicName: surah.arabicName,
                    englishName: surah.englishName,
                    revelationType: surah.revelationType.rawValue,
                    ayahCount: surah.ayahCount,
                    page: surah.pageStart
                ) {
                    viewModel.navigateToSurah(surah)
                }
            }
        }
    }

    // MARK: – Search results view (Semantic tab)
    var searchResultsView: some View {
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

    // MARK: – Empty state
    var emptyStateView: some View {
        VStack(spacing: DSSpacing.lg) {
            if viewModel.selectedCategory == .tafsir {
                Image(systemName: "book.closed")
                    .font(.system(size: 64))
                    .foregroundColor(dsColors.textHint)
                    .padding(.top, 40)

                VStack(spacing: DSSpacing.xs) {
                    Text("No Surahs Found")
                        .dsFont(DSTypography.titleLarge)
                        .foregroundColor(dsColors.textPrimary)

                    Text("Try searching by the Surah name (e.g. \"Al-Fatiha\") or its number (e.g. \"1\").")
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DSSpacing.lg)
                }
            } else {
                Image("search_empty_state", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)

                VStack(spacing: DSSpacing.xs) {
                    Text("No Results Found")
                        .dsFont(DSTypography.titleLarge)
                        .foregroundColor(dsColors.textPrimary)

                    Text("We couldn't find anything matching your search.\nTry checking for typos or searching with different keywords.")
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DSSpacing.lg)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}

