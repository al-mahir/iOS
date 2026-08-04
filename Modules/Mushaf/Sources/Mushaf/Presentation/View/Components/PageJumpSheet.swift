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

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    private enum JumpMode: String, CaseIterable, Identifiable {
        case surah = "Surah"
        case juz = "Juz'"
        case page = "Page"

        var id: String { rawValue }
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
                Picker("Go to", selection: $mode) {
                    ForEach(JumpMode.allCases) { mode in
                        Text(mode.rawValue)
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
            .navigationTitle("Go to Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
                        Text("\(surah.ayahCount) Ayahs")
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
            .listRowBackground(dsColors.surface)
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search surah")
    }

    // MARK: - Juz tab

    private var juzListView: some View {
        List(juzList, id: \.id) { juz in
            Button {
                onSubmit(juz.pageStart)
                dismiss()
            } label: {
                HStack {
                    Text("Juz' \(juz.number)")
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer()

                    Text("Page \(juz.pageStart)")
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
                TextField("Page number (1–\(totalPages))", text: $pageInput)
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
                    Text("Go")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(DSPrimaryButtonStyle())
            }
        }
        .onAppear { isPageFieldFocused = true }
    }

    private func submitPage() {
        guard let number = Int(pageInput) else {
            errorText = "Enter a valid number."
            return
        }
        guard (1...totalPages).contains(number) else {
            errorText = "Page must be between 1 and \(totalPages)."
            return
        }
        onSubmit(number)
        dismiss()
    }
}
