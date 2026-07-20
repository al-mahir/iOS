//
//  SemanticFilterSheet.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
struct SemanticFilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                List {
                    Section(header: Text("Tafsir Type").foregroundColor(.gray)) {
                        ForEach(TafsirType.allCases, id: \.self) { tafsir in
                            HStack {
                                Text(tafsir.rawValue)
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedTafsirType == tafsir {
                                    Image(systemName: "circle.inset.filled")
                                        .foregroundColor(AppColors.primaryAccent)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectedTafsirType = tafsir
                            }
                            .listRowBackground(AppColors.surface)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Semantic Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryAccent)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
