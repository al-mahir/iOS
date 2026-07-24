//
//  WordSearchResultsView.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


import SwiftUI
import Common

struct WordSearchResultsView: View {
    @Environment(\.dsColors) private var dsColors
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            if !viewModel.filteredWordSurahs.isEmpty {
                surahSection
            }
            if !viewModel.wordMatchedAyahs.isEmpty {
                ayahSection
            }
        }
    }

    // MARK: - Surah Section

    private var surahSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            ForEach(viewModel.filteredWordSurahs, id: \.id) { surah in
                AppSurahCard(
                    surahNumber: surah.id,
                    arabicName: surah.arabicName,
                    englishName: surah.englishName,
                    revelationType: surah.revelationType.rawValue,
                    ayahCount: surah.ayahCount,
                    page: surah.pageStart
                ) {
                    viewModel.navigateToSurah(surah)
                }
            }
        }
    }

    // MARK: - Ayah Section

    private var ayahSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            ForEach(viewModel.wordMatchedAyahs) { result in
                Button {
                    viewModel.navigateToAyah(result)
                } label: {
                    VStack(alignment: .trailing, spacing: DSSpacing.xs) {
                        HStack {
                            Spacer()
                            Text("\(result.surah.englishName) - Ayah \(result.ayah.number)")
                                .dsFont(DSTypography.labelSmall)
                                .foregroundColor(dsColors.textSecondary)
                        }

                        Text(result.ayah.arabicText)
                            .dsArabicFont(DSTypography.bodyLarge)
                            .foregroundColor(dsColors.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .lineSpacing(6)
                    }
                    .padding(DSSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .fill(dsColors.surfaceContainerLow)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(dsColors.outlineVariant, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
