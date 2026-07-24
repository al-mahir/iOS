//
//  TafsirSearchResultsView.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


//
//  TafsirSearchResultsView.swift
//  Search
//

import SwiftUI
import Common

/// Shown in the Tafsir tab when the user has typed a search query.
/// Displays matching Surahs (with expandable Ayah picker grid) and matching Ayahs (with Read Tafsir buttons).
struct TafsirSearchResultsView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dsColors) private var dsColors

    /// Tracks which surah id is currently expanded to show Ayah chips
    @State private var expandedSurahId: Int? = nil
    /// Tracks the currently loading ayah combination
    @State private var loadingAyah: (surah: Int, ayah: Int)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            if !viewModel.tafsirMatchedSurahs.isEmpty {
                surahSection
            }

            if !viewModel.tafsirMatchedAyahs.isEmpty {
                ayahSection
            }
        }
    }

    // MARK: - Surah Section

    private var surahSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "book.pages")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dsColors.primary)
                Text("\(viewModel.tafsirMatchedSurahs.count) Surah\(viewModel.tafsirMatchedSurahs.count == 1 ? "" : "s") found")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xs)

            ForEach(viewModel.tafsirMatchedSurahs, id: \.id) { surah in
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            expandedSurahId = expandedSurahId == surah.id ? nil : surah.id
                        }
                    } label: {
                        HStack(spacing: DSSpacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DSRadius.sm)
                                    .fill(dsColors.primaryContainer)
                                    .frame(width: 42, height: 42)
                                Text("\(surah.id)")
                                    .dsFont(DSTypography.labelLarge)
                                    .foregroundColor(dsColors.onPrimaryContainer)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(surah.englishName)
                                    .dsFont(DSTypography.titleMedium)
                                    .foregroundColor(dsColors.textPrimary)
                                    .lineLimit(1)

                                HStack(spacing: DSSpacing.xs) {
                                    Text(surah.arabicName)
                                        .dsArabicFont(DSTypography.titleMedium)
                                        .foregroundColor(dsColors.textSecondary)
                                    Text("•")
                                        .foregroundColor(dsColors.textHint)
                                    Text("\(surah.ayahCount) Ayahs")
                                        .dsFont(DSTypography.bodySmall)
                                        .foregroundColor(dsColors.textSecondary)
                                    Text("•")
                                        .foregroundColor(dsColors.textHint)
                                    Text(surah.revelationType.rawValue)
                                        .dsFont(DSTypography.bodySmall)
                                        .foregroundColor(dsColors.textSecondary)
                                }
                                .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: expandedSurahId == surah.id ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(dsColors.textSecondary)
                                .animation(.easeInOut(duration: 0.2), value: expandedSurahId)
                        }
                        .padding(DSSpacing.smMd)
                    }
                    .buttonStyle(.plain)
                    .background(dsColors.surfaceContainerLow)
                    .cornerRadius(DSRadius.md)

                    if expandedSurahId == surah.id {
                        ayahGrid(for: surah)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .background(dsColors.surfaceContainerLow)
                .cornerRadius(DSRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(
                            expandedSurahId == surah.id ? dsColors.primary.opacity(0.4) : dsColors.outlineVariant.opacity(0.3),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    // MARK: - Ayah Section

    private var ayahSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "text.quote")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dsColors.primary)
                Text("\(viewModel.tafsirMatchedAyahs.count) Ayah\(viewModel.tafsirMatchedAyahs.count == 1 ? "" : "s") found")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.xs)

            ForEach(viewModel.tafsirMatchedAyahs) { result in
                let isLoading = loadingAyah?.surah == result.surah.id && loadingAyah?.ayah == result.ayah.number

                Button {
                    guard !viewModel.isFetchingTafsir else { return }
                    loadingAyah = (surah: result.surah.id, ayah: result.ayah.number)
                    viewModel.fetchTafsirForAyah(surah: result.surah.id, ayah: result.ayah.number)
                } label: {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            Text("\(result.surah.englishName) - Ayah \(result.ayah.number)")
                                .dsFont(DSTypography.labelMedium)
                                .foregroundColor(dsColors.primary)

                            Spacer()

                            HStack(spacing: 4) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .tint(dsColors.primary)
                                } else {
                                    Image(systemName: "book.pages")
                                        .font(.system(size: 12))
                                    Text("Read Tafsir")
                                        .dsFont(DSTypography.labelSmall)
                                }
                            }
                            .foregroundColor(dsColors.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(dsColors.primaryContainer.opacity(0.4))
                            .cornerRadius(12)
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
                .disabled(viewModel.isFetchingTafsir)
            }
        }
    }

    // MARK: - Ayah grid

    private func ayahGrid(for surah: Surah) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Divider()
                .background(dsColors.outlineVariant)
                .padding(.horizontal, DSSpacing.smMd)

            Text("Select an Ayah to view Tafsir")
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textSecondary)
                .padding(.horizontal, DSSpacing.smMd)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
                spacing: 8
            ) {
                ForEach(1...surah.ayahCount, id: \.self) { ayahNum in
                    let isLoading = loadingAyah?.surah == surah.id && loadingAyah?.ayah == ayahNum

                    Button {
                        guard !viewModel.isFetchingTafsir else { return }
                        loadingAyah = (surah: surah.id, ayah: ayahNum)
                        viewModel.fetchTafsirForAyah(surah: surah.id, ayah: ayahNum)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isLoading ? dsColors.primary : dsColors.surfaceContainer)

                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.6)
                                    .tint(.white)
                            } else {
                                Text("\(ayahNum)")
                                    .dsFont(DSTypography.labelSmall)
                                    .foregroundColor(dsColors.textPrimary)
                            }
                        }
                        .frame(height: 36)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isFetchingTafsir)
                }
            }
            .padding(.horizontal, DSSpacing.smMd)
            .padding(.bottom, DSSpacing.smMd)
        }
        .onChange(of: viewModel.isFetchingTafsir) { fetching in
            if !fetching { loadingAyah = nil }
        }
    }
}
