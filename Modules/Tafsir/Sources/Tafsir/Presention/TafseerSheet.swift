//
//  TafseerSheet.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import SwiftUI
import Common
import Combine

public struct TafseerSheet: View {
    let surah: Int
    let ayah: Int
    let arabicText: String
    let surahDisplayName: String
    let fontName: String?
    var isTajweedEnabled: Bool = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var viewModel: TafseerSheetViewModel
    @State private var isBookmarked: Bool
    @State private var isShowingManagement = false

    private let onToggleBookmark: () -> Void

    public init(
        surah: Int,
        ayah: Int,
        arabicText: String,
        surahDisplayName: String,
        isAyahBookmarked: Bool,
        fontName: String? = nil,
        isTajweedEnabled: Bool = true,
        onToggleBookmark: @escaping () -> Void,
        useCases: TafsirUseCases = TafsirUseCases(repository: TafsirRepository())
    ) {
        self.surah = surah
        self.ayah = ayah
        self.arabicText = arabicText
        self.surahDisplayName = surahDisplayName
        self.fontName = fontName
        self.isTajweedEnabled = isTajweedEnabled
        self.onToggleBookmark = onToggleBookmark
        _isBookmarked = State(initialValue: isAyahBookmarked)
        _viewModel = StateObject(wrappedValue: TafseerSheetViewModel(surah: surah, ayah: ayah, useCases: useCases))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    // Header Info
                    Text("\(surahDisplayName) : \(ayah)")
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.textSecondary)

                    // Ayah Arabic Text
                    if !arabicText.isEmpty {
                        Text(arabicText)
                            .font(quranFont(size: 24))
                            .foregroundColor(dsColors.textPrimary)
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(8)
                            .modifier(
                                QuranTextDarkModeModifier(
                                    isDarkMode: colorScheme == .dark,
                                    isTajweed: isTajweedEnabled
                                )
                            )
                            .frame(maxWidth: .infinity)
                    }

                    Divider()
                        .overlay(dsColors.divider)

                    // Main Tafsir Text / Content
                    tafsirContent
                }
                .padding(DSSpacing.md)
            }
            .background(dsColors.background.ignoresSafeArea())
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done", bundle: .module)
                            .dsFont(DSTypography.buttonText)
                            .foregroundColor(dsColors.textLink)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    switcherMenu
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isBookmarked.toggle()
                        onToggleBookmark()
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isBookmarked ? dsColors.primary : dsColors.textPrimary)
                    }
                }
            }
            .navigationTitle(Text("Tafsir", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingManagement) {
                TafsirManagementView()
                    .onDisappear { viewModel.loadDownloadedTafsirs() }
            }
        }
        .dsTheme()
        .onAppear { viewModel.load() }
        .onDisappear {
            viewModel.cancelAllRequests()
        }
    }

    // MARK: - Font Helper

    private func quranFont(size: CGFloat) -> Font {
        if let fontName, !fontName.isEmpty {
            return .custom(fontName, size: size)
        }
        return .custom("AmiriQuran-Regular", size: size)
    }

    // MARK: - Content

    @ViewBuilder
    private var tafsirContent: some View {
        if viewModel.isLoadingText {
            ProgressView()
                .tint(dsColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, DSSpacing.lg)
        } else if !viewModel.tafsirText.isEmpty {
            Text(viewModel.tafsirText)
                .dsFont(DSTypography.bodyLarge)
                .foregroundColor(dsColors.textPrimary)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.error)
        } else if viewModel.downloadedTafsirs.isEmpty {
            emptyStateView
        } else {
            Text("No tafsir text available", bundle: .module)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DSSpacing.smMd) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 32))
                .foregroundColor(dsColors.textSecondary)
            
            Text("No tafsirs downloaded yet", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
            
            Button {
                isShowingManagement = true
            } label: {
                Text("Download a Tafsir", bundle: .module)
            }
            .buttonStyle(DSPrimaryButtonStyle())
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.lg)
    }

    // MARK: - Switcher

    private var availableTafseers: [TafsirInfo] {
        if viewModel.downloadedTafsirs.isEmpty {
            return [
                TafsirInfo(
                    tafsirKey: "ibn-kathir",
                    displayName: "تفسير ابن كثير",
                    language: "ar",
                    languageName: "العربية",
                    downloadUrl: "",
                    fileSizeBytes: 0,
                    isDownloaded: false
                )
            ]
        }
        return viewModel.downloadedTafsirs
    }

    private var switcherMenu: some View {
        Menu {
            ForEach(availableTafseers) { tafsir in
                Button {
                    viewModel.select(tafsir.tafsirKey)
                } label: {
                    if tafsir.tafsirKey == viewModel.selectedTafsirKey {
                        Label(tafsir.displayName, systemImage: "checkmark")
                    } else {
                        Text(tafsir.displayName)
                    }
                }
            }

            Divider()

            Button {
                isShowingManagement = true
            } label: {
                Label {
                    Text("Manage Tafseers", bundle: .module)
                } icon: {
                    Image(systemName: "plus.circle")
                }
            }
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Text(currentTafsirDisplayName)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(dsColors.textSecondary)
            }
        }
    }

    private var currentTafsirDisplayName: String {
        if let found = availableTafseers.first(where: { $0.tafsirKey == viewModel.selectedTafsirKey }) {
            return found.displayName
        }
        if viewModel.selectedTafsirKey == "ibn-kathir" {
            return "تفسير ابن كثير"
        }
        return String(localized: "Tafsir", bundle: .module)
    }
}
