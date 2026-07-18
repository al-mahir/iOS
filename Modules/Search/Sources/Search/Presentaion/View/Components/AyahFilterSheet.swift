//
//  AyahFilterSheet.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//
import SwiftUI

struct AyahFilterSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                List {
                    Section(header: Text("Filter by Surah (Multi-select)").foregroundColor(.gray)) {
                        ForEach(viewModel.allSurahs) { surah in
                            HStack {
                                Text(surah.englishName)
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedSurahIds.contains(surah.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primaryAccent)
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
                            .listRowBackground(AppColors.surface)
                        }
                    }
                    
                    Section(header: Text("Filter by Juz' (Multi-select)").foregroundColor(.gray)) {
                        ForEach(viewModel.allJuz) { juz in
                            HStack {
                                Text("Juz' \(juz.number)")
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedJuzNumbers.contains(juz.number) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primaryAccent)
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
                            .listRowBackground(AppColors.surface)
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
                    .foregroundColor(AppColors.primaryAccent)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
