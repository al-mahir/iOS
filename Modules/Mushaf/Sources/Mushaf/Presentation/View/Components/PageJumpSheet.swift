//
//  PageJumpSheet.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI

struct PageJumpSheet: View {
    let totalPages: Int
    let currentPage: Int
    
    let onSubmit: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

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
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                switch mode {
                case .surah:
                    surahListView
                case .juz:
                    juzListView
                case .page:
                    pageEntryView
                }
            }
            .navigationTitle("Go to Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.englishName)
                            .font(.body)
                        Text("\(surah.ayahCount) Ayahs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(surah.arabicName)
                        .font(.body)

                    Text("\(surah.pageStart)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: 32, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
                        .font(.body)

                    Spacer()

                    Text("Page \(juz.pageStart)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
    }

    // MARK: - Page tab

    private var pageEntryView: some View {
        Form {
            Section {
                TextField("Page number (1–\(totalPages))", text: $pageInput)
                    .keyboardType(.numberPad)
                    .focused($isPageFieldFocused)
                    .onSubmit(submitPage)

                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Go", action: submitPage)
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
