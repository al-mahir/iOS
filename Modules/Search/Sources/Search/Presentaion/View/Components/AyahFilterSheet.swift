//
//  AyahFilterSheet.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//
import SwiftUI
import Common

struct AyahFilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.dsColors) private var dsColors
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                dsColors.background.ignoresSafeArea()
                List {
                    Section(header: Text("Filter by Surah (Multi-select)").foregroundColor(dsColors.textSecondary)) {
                        ForEach(viewModel.allSurahs) { surah in
                            HStack {
                                Text(surah.englishName)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)
                                Spacer()
                                if viewModel.selectedSurahIds.contains(surah.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(dsColors.primary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.selectedSurahIds.contains(surah.id) {
                                    viewModel.selectedSurahIds.remove(surah.id)
                                } else {
                                    viewModel.selectedSurahIds.insert(surah.id)
                                }
                            }
                            .listRowBackground(dsColors.surface)
                        }
                    }
                    
                    Section(header: Text("Filter by Juz' (Multi-select)").foregroundColor(dsColors.textSecondary)) {
                        ForEach(viewModel.allJuz) { juz in
                            HStack {
                                Text("Juz' \(juz.number)")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)
                                Spacer()
                                if viewModel.selectedJuzNumbers.contains(juz.number) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(dsColors.primary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.selectedJuzNumbers.contains(juz.number) {
                                    viewModel.selectedJuzNumbers.remove(juz.number)
                                } else {
                                    viewModel.selectedJuzNumbers.insert(juz.number)
                                }
                            }
                            .listRowBackground(dsColors.surface)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                    .foregroundColor(dsColors.primary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(dsColors.textSecondary)
                }
            }
        }
    }
}
