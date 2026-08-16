//
//  SemanticFilterSheet.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common

struct SemanticFilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dsColors) private var dsColors
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                dsColors.background.ignoresSafeArea()
                List {
                    Section(header: Text("Tafsir Type", bundle: .module).foregroundColor(dsColors.textSecondary)) {
                        ForEach(TafsirType.allCases, id: \.self) { tafsir in
                            HStack {
                                Text(tafsir.rawValue)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)
                                Spacer()
                                Image(systemName: viewModel.selectedTafsirType == tafsir ? "circle.inset.filled" : "circle")
                                    .foregroundColor(viewModel.selectedTafsirType == tafsir ? dsColors.primary : dsColors.textDisabled)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedTafsirType = tafsir
                            }
                            .listRowBackground(dsColors.surface)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Text("Semantic Filter", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.applyFilters()
                        dismiss()
                    } label: {
                        Text("Apply", bundle: .module)
                    }
                    .foregroundColor(dsColors.primary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel", bundle: .module)
                    }
                    .foregroundColor(dsColors.textSecondary)
                }
            }
        }
    }
}
