//
//  SurahPickerSheet.swift
//  Listening
//

import SwiftUI
import Common

/// Sheet displaying all 114 Surahs of the Quran for quick switching during audio playback.
public struct SurahPickerSheet: View {

    @ObservedObject private var viewModel: ListeningViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""

    public init(viewModel: ListeningViewModel) {
        self.viewModel = viewModel
    }

    private var filteredSurahs: [SurahItem] {
        if searchText.isEmpty { return SurahData.surahs }
        return SurahData.surahs.filter {
            $0.englishName.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            "\($0.number)".contains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                dsColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.sm)

                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: DSSpacing.xs) {
                                ForEach(filteredSurahs, id: \.number) { item in
                                    surahRow(item)
                                        .id(item.number)
                                }
                            }
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.bottom, DSSpacing.xl)
                        }
                        .onAppear {
                            proxy.scrollTo(viewModel.currentChapterNumber, anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle(Text("Select Surah", bundle: CommonBundle.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done", bundle: CommonBundle.bundle)) { dismiss() }
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.primary)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
            TextField(String(localized: "Search surah name or number…", bundle: CommonBundle.bundle), text: $searchText)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
        }
        .padding(DSSpacing.smMd)
        .background(dsColors.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }

    // MARK: - Surah Row

    private func surahRow(_ item: SurahItem) -> some View {
        let isPlaying = viewModel.currentChapterNumber == item.number

        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            viewModel.activateListeningMode(surahNumber: item.number, surahName: item.englishName, startAyah: 1)
            dismiss()
        } label: {
            HStack(spacing: DSSpacing.smMd) {
                // Number badge
                ZStack {
                    Circle()
                        .fill(isPlaying ? dsColors.primary : dsColors.surfaceContainerHigh)
                        .frame(width: 36, height: 36)
                    Text("\(item.number)")
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(isPlaying ? dsColors.onPrimary : dsColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.localizedName)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(isPlaying ? dsColors.primary : dsColors.textPrimary)

                    Text("\(item.ayahs) Verses", bundle: CommonBundle.bundle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                }

                Spacer()

                Text(item.localizedName == item.name ? item.englishName : item.name)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(isPlaying ? dsColors.primary : dsColors.textPrimary)

                if isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(dsColors.primary)
                        .font(.system(size: 16))
                        .padding(.leading, 4)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(isPlaying ? dsColors.primaryContainer.opacity(0.2) : dsColors.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: DSRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(isPlaying ? dsColors.primary.opacity(0.4) : dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
