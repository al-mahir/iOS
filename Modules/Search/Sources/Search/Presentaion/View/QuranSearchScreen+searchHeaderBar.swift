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
                Text("Search")
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
                
                
                Button(action: {
                    viewModel.toggleVoiceRecording()
                }) {
                    ZStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(viewModel.isListening ? .red : AppColors.primaryAccent)
                        
                        if viewModel.isListening {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: 28, height: 28)
                                .scaleEffect(viewModel.isListening ? 1.2 : 1.0)
                                .opacity(viewModel.isListening ? 0.5 : 0)
                                .animation(
                                    Animation.easeInOut(duration: 0.8)
                                        .repeatForever(autoreverses: true),
                                    value: viewModel.isListening
                                )
                        }
                    }
                }
                .disabled(!viewModel.isSpeechAvailable() && !viewModel.isListening)
                .opacity(viewModel.isSpeechAvailable() || viewModel.isListening ? 1.0 : 0.5)
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
