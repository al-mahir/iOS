//
//  Untitled.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common

extension QuranSearchScreen {
    var searchHeaderBar: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Search")
                    .dsFont(DSTypography.headlineLarge)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.md)
            
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(dsColors.textSecondary)
                
                TextField("", text: $viewModel.searchQuery, prompt:
                    Text(getSearchPlaceholder())
                        .foregroundColor(dsColors.textHint)
                )
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .disableAutocorrection(true)
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.clearSearch() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
                
                Button(action: { viewModel.toggleVoiceRecording() }) {
                    ZStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(viewModel.isListening ? dsColors.error : dsColors.primary)
                        
                        if viewModel.isListening {
                            Circle()
                                .stroke(dsColors.error, lineWidth: 2)
                                .frame(width: 28, height: 28)
                                .scaleEffect(viewModel.isListening ? 1.2 : 1.0)
                                .opacity(viewModel.isListening ? 0.5 : 0)
                                .animation(
                                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: viewModel.isListening
                                )
                        }
                    }
                }
                .disabled(!viewModel.isSpeechAvailable() && !viewModel.isListening)
                .opacity(viewModel.isSpeechAvailable() || viewModel.isListening ? 1.0 : 0.5)
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.md)
            .padding(.horizontal, DSSpacing.md)
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
    
   

