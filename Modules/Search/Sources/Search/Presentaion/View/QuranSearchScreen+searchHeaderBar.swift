//
//  Untitled.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
extension QuranSearchScreen {
    var searchHeaderBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Search & Index")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("", text: $viewModel.searchQuery, prompt:
                    Text(getSearchPlaceholder())
                        .foregroundColor(.gray)
                )
                .foregroundColor(.white)
                .disableAutocorrection(true)
                .onChange(of: viewModel.searchQuery) { _ in
                    // The debouncer in ViewModel handles the search
                }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { /* Voice Search */ }) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(AppColors.primaryAccent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.field)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    private func getSearchPlaceholder() -> String {
        switch viewModel.selectedCategory {
        case .surah:
            return "Search Surah name..."
        case .juz:
            return "Search Juz' number..."
        case .ayah, .semantic:
            return "Search Ayah, Keyword..."
        }
    }
}
