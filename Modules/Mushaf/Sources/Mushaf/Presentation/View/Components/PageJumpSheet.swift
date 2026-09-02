//
//  PageJumpSheet.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI
import Common

struct PageJumpSheet: View {
    let totalPages: Int
    let currentPage: Int

    let onSubmit: (Int) -> Void
    var isSurahBookmarked: ((Int) -> Bool)? = nil
    var onToggleSurahBookmark: ((Int) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    private enum JumpMode: String, CaseIterable, Identifiable {
        case surah, juz, page

        var id: String { rawValue }

        var localizedTitle: LocalizedStringKey {
            switch self {
            case .surah: return LocalizedStringKey("Surah")
            case .juz:   return LocalizedStringKey("Juz'")
            case .page:  return LocalizedStringKey("Page")
            }
        }
    }

    @State private var mode: JumpMode = .surah
    @State private var searchText: String = ""

    // Page tab state
    @State private var pageInput: String = ""
    @State private var errorText: String?
    @FocusState private var isPageFieldFocused: Bool

    private let surahs = MockDataService.shared.getAllSurahs()
    private let juzList = MockDataService.shared.getAllJuz()

    private var filteredSurahs: [Surah] {
        guard !searchText.isEmpty else { return surahs }
        return surahs.filter {
            $0.englishName.localizedCaseInsensitiveContains(searchText) ||
            $0.arabicName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(String(localized: "Go to", bundle: .module), selection: $mode) {
                    ForEach(JumpMode.allCases) { mode in
                        Text(mode.localizedTitle, bundle: .module)
                            .dsFont(DSTypography.bodyMedium)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.xs)
                .onAppear {
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(dsColors.primary)
                    
                    UISegmentedControl.appearance().setTitleTextAttributes(
                        [.foregroundColor: UIColor(dsColors.onPrimary)],
                        for: .selected
                    )
                    
                    UISegmentedControl.appearance().setTitleTextAttributes(
                        [.foregroundColor: UIColor(dsColors.textSecondary)],
                        for: .normal
                    )
                }

                switch mode {
                case .surah:
                    surahListView
                case .juz:
                    juzListView
                case .page:
                    pageEntryView
                }
            }
            .background(dsColors.background)
            .navigationTitle(String(localized: "Go to Page", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel", bundle: .module)) { dismiss() }
                        .dsFont(DSTypography.buttonText)
                        .foregroundStyle(dsColors.primary)
                }
            }
        }
        .onAppear {
            pageInput = "\(currentPage)"
        }
    }

    // MARK: - Surah tab

    private var surahListView: some View {
        List(filteredSurahs, id: \.id) { surah in
            HStack(spacing: DSSpacing.sm) {
                // Surah info — tapping navigates
                Button {
                    onSubmit(surah.pageStart)
                    dismiss()
                } label: {
                    HStack {
                        Text("\(surah.id)")
                            .dsFont(DSTypography.caption)
                            .foregroundStyle(dsColors.textSecondary)
                            .frame(width: 28, alignment: .leading)

                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text(surah.englishName)
                                .dsFont(DSTypography.bodyMedium)
                                .foregroundStyle(dsColors.textPrimary)
                            Text("\(surah.ayahCount) Ayahs", bundle: .module)
                                .dsFont(DSTypography.caption)
                                .foregroundStyle(dsColors.textSecondary)
                        }

                        Spacer()

                        Text(surah.arabicName)
                            .dsArabicFont(DSTypography.bodyLarge)
                            .foregroundStyle(dsColors.textPrimary)

                        Text("\(surah.pageStart)")
                            .dsFont(DSTypography.caption)
                            .foregroundStyle(dsColors.textSecondary)
                            .frame(width: 32, alignment: .trailing)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Surah bookmark toggle (only shown when callbacks are provided)
                if let isSurahBookmarked, let onToggleSurahBookmark {
                    let isBookmarked = isSurahBookmarked(surah.id)
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onToggleSurahBookmark(surah.id)
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(isBookmarked ? dsColors.primary : dsColors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(isBookmarked ? dsColors.primaryContainer : dsColors.surfaceContainerLow)
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isBookmarked)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listRowBackground(dsColors.surface)
        }
        .listStyle(.plain)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search surah", bundle: .module)
        )
    }

    // MARK: - Juz tab

    private var juzListView: some View {
        List(juzList, id: \.id) { juz in
            Button {
                onSubmit(juz.pageStart)
                dismiss()
            } label: {
                HStack {
                    Text("Juz' \(juz.number)", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer()

                    Text("Page \(juz.pageStart)", bundle: .module)
                        .dsFont(DSTypography.caption)
                        .foregroundStyle(dsColors.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowBackground(dsColors.surface)
        }
        .listStyle(.plain)
    }

    // MARK: - Page tab

    private var pageEntryView: some View {
        Form {
            Section {
                TextField(
                    String(localized: "Page number (1–\(totalPages))", bundle: .module),
                    text: $pageInput
                )
                .dsFont(DSTypography.bodyMedium)
                .keyboardType(.numberPad)
                .focused($isPageFieldFocused)
                .onSubmit(submitPage)

                if let errorText {
                    Text(errorText)
                        .dsFont(DSTypography.inputError)
                        .foregroundStyle(dsColors.error)
                }
            }

            Section {
                Button(action: submitPage) {
                    Text("Go", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(DSPrimaryButtonStyle())
            }
        }
        .onAppear { isPageFieldFocused = true }
    }

    private func submitPage() {
        guard let number = Int(pageInput) else {
            errorText = String(
                localized: "Enter a valid number.",
                bundle: .module,
                comment: "Error shown when page input is not a valid integer"
            )
            return
        }
        guard (1...totalPages).contains(number) else {
            errorText = String(
                localized: "Page must be between 1 and \(totalPages).",
                bundle: .module,
                comment: "Error shown when entered page is out of valid bounds"
            )
            return
        }
        onSubmit(number)
        dismiss()
    }
}
