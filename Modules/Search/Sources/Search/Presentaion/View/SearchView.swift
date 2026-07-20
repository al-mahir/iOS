//
//  SwiftUIView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Mushaf

public struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            QuranSearchScreen(viewModel: viewModel)
        }
        .navigationViewStyle(.stack)
    }
}

struct QuranSearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var showAyahFilterSheet = false
    @State private var showSemanticFilterSheet = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                searchHeaderBar
                categorySegmentedControl
                filterTriggerRow
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else if viewModel.searchQuery.isEmpty {
                            
                            defaultStateView
                            contentView
                        } else {
                            if isCurrentCategoryEmpty {
                                emptyStateView
                            } else {
                                contentView
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .sheet(isPresented: $showAyahFilterSheet) {
            AyahFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSemanticFilterSheet) {
            SemanticFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .background(
            NavigationLink(
                destination:
                MushafRootView(startPage: viewModel.selectedPageNumber ?? 1),
                isActive: $viewModel.navigateToMushaf
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    private var isCurrentCategoryEmpty: Bool {
        switch viewModel.selectedCategory {
        case .surah:
            return viewModel.filteredSurahs.isEmpty
        case .juz:
            return viewModel.filteredJuz.isEmpty
        case .ayah, .semantic:
            return viewModel.searchResults.isEmpty
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.selectedCategory == .surah {
            surahListView
        } else if viewModel.selectedCategory == .juz {
            juzListView
        } else {
            searchResultsView
        }
    }
    
    private var surahListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.searchQuery.isEmpty {
                Text("Results for '\(viewModel.searchQuery)'")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            ForEach(viewModel.filteredSurahs.prefix(20)) { surah in
                SurahListItem(surah: surah)
                    .onTapGesture {
                        viewModel.selectedPageNumber = surah.pageStart
                        viewModel.navigateToMushaf = true
                    }
            }
        }
    }
    
    private var juzListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.searchQuery.isEmpty {
                Text("Results for '\(viewModel.searchQuery)'")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            ForEach(viewModel.filteredJuz.prefix(20)) { juz in
                JuzListItem(juz: juz)
                    .onTapGesture {
                        viewModel.selectedPageNumber = juz.pageStart
                        viewModel.navigateToMushaf = true
                    }
            }
        }
    }
    @ViewBuilder
        private var filterTriggerRow: some View {
            if viewModel.selectedCategory == .ayah || viewModel.selectedCategory == .semantic {
                HStack {
                    if viewModel.hasActiveFilters {
                        Button(action: { viewModel.clearFilters() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Clear Filters")
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.selectedCategory == .ayah { showAyahFilterSheet = true }
                        if viewModel.selectedCategory == .semantic { showSemanticFilterSheet = true }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                            Text(viewModel.hasActiveFilters ? "Filters Active" : "Filter Search")
                        }
                        .font(.footnote)
                        .foregroundColor(AppColors.primaryAccent)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(AppColors.surface)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
}

