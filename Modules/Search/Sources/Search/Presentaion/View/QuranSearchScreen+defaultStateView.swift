//
//  File.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation
import SwiftUI

extension QuranSearchScreen {
    var defaultStateView: some View {
        VStack(alignment: .leading, spacing: 16) {                if !viewModel.currentCategoryHistory.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Button("Clear All") {
                        viewModel.clearSearchHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.currentCategoryHistory) { history in
                            HStack(spacing: 6) {
                                Text(history.query)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Button(action: {
                                    viewModel.deleteFromHistory(history)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(AppColors.surface)
                            .cornerRadius(16)
                            .onTapGesture {
                                viewModel.searchQuery = history.query
                            }
                        }
                    }
                }
            Divider().background(AppColors.border)
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
        VStack(alignment: .leading, spacing: 14) {
            Text("Results for '\(viewModel.searchQuery)'")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ForEach(viewModel.searchResults) { result in
                SearchResultCard(result: result) {
                    viewModel.navigateToAyah(result)
                }
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No results found")
                .font(.headline)
                .foregroundColor(.white)
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
