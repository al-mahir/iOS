//
//  File.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//


import SwiftUI
import Common

extension QuranSearchScreen {
    @ViewBuilder
    var defaultStateView: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            if !viewModel.currentCategoryHistory.isEmpty {
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
                            .background(RoundedRectangle(cornerRadius: DSRadius.lg).fill(dsColors.surfaceContainerHigh))
                            .onTapGesture { viewModel.searchQuery = history.query }
                        }
                    }
                }
                Divider().background(dsColors.divider)
            }
            
            if viewModel.selectedCategory == .surah {
                SurahListView(surahs: viewModel.filteredSurahs) { selectedSurah in
                    viewModel.selectedPageNumber = selectedSurah.pageStart
                    viewModel.navigateToMushaf = true
                }
            } else if viewModel.selectedCategory == .juz {
                JuzListView(juz: viewModel.filteredJuz) { selectedJuz in
                    viewModel.selectedPageNumber = selectedJuz.pageStart
                    viewModel.navigateToMushaf = true
                }
            }
        }
    }
    
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
    
    var emptyStateView: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(dsColors.textDisabled)
            
            Text("No results found")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
            
            Text("Try adjusting your search or filters")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
