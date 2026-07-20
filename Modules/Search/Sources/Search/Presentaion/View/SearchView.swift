//
//  SwiftUIView.swift
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
        NavigationView {
            QuranSearchScreen(viewModel: viewModel)
        }
        .navigationViewStyle(.stack)
    }
}

struct QuranSearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dsColors) var dsColors
    
    @State private var showAyahFilterSheet = false
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
                        if viewModel.isSearching {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                                .tint(dsColors.primary)
                        } else if viewModel.searchQuery.isEmpty {
                            defaultStateView
                        } else {
                            if isCurrentCategoryEmpty {
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
        .alert("Permission Required", isPresented: $viewModel.permissionDenied) {
            Button("Settings", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant microphone and speech recognition permissions in Settings.")
        }
        .background(
            NavigationLink(
                destination: MushafRootView(startPage: viewModel.selectedPageNumber ?? 1),
                isActive: $viewModel.navigateToMushaf
            ) { EmptyView() }.hidden()
        )
    }
    

    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    private var isCurrentCategoryEmpty: Bool {
        switch viewModel.selectedCategory {
        case .surah: return viewModel.filteredSurahs.isEmpty
        case .juz: return viewModel.filteredJuz.isEmpty
        case .ayah, .semantic: return viewModel.searchResults.isEmpty
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
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
        } else {
            searchResultsView
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
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.error)
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
