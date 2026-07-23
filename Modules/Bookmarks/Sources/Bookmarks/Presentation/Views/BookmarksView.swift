//
//  BookmarksView.swift
//  Bookmarks (Presentation)
//

import SwiftUI
import Common

public struct BookmarksView: View {
    @StateObject private var viewModel: BookmarksViewModel
    @Environment(\.dsColors) private var dsColors

    // MARK: - Injected dependencies

    /// Returns the PostScript Quran font name for a given page number.
    /// Provided by the caller (main app) to avoid a circular
    /// Bookmarks → Mushaf dependency.
    private let quranFontProvider: ((Int) -> String?)?

    /// Navigation callbacks — the caller (MainTabView) handles presenting
    /// the Mushaf at the correct page / ayah.
    private let onNavigateToPage: ((Int) -> Void)?
    private let onNavigateToAyah: ((Int, Int) -> Void)?   // (pageNumber, ayahNumber)
    private let onNavigateToSurah: ((Int) -> Void)?       // startPage

    // MARK: - Init

    public init(
        container: BookmarksDependencyContainer,
        quranFontProvider: ((Int) -> String?)? = nil,
        onNavigateToPage: ((Int) -> Void)? = nil,
        onNavigateToAyah: ((Int, Int) -> Void)? = nil,
        onNavigateToSurah: ((Int) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: container.makeBookmarksViewModel())
        self.quranFontProvider  = quranFontProvider
        self.onNavigateToPage   = onNavigateToPage
        self.onNavigateToAyah   = onNavigateToAyah
        self.onNavigateToSurah  = onNavigateToSurah
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            header

            BookmarkSearchField(text: $viewModel.searchText)
                .padding(.horizontal, DSSpacing.md)

            BookmarkTabPicker(selectedTab: $viewModel.selectedTab)
                .padding(.horizontal, DSSpacing.md)

            if viewModel.isCurrentTabEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                list
            }
        }
        .background(dsColors.background)
        .task {
            // .task fires on every appearance (like .onAppear), but is
            // properly MainActor-isolated and cancels when the view disappears.
            viewModel.loadAll()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Sub-views

    private var header: some View {
        Text("Bookmarks")
            .dsFont(DSTypography.headlineSmall)
            .foregroundColor(dsColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.md)
    }

    // List (not ScrollView+LazyVStack) so swipe-to-remove is available.
    private var list: some View {
        List {
            switch viewModel.selectedTab {
            case .surah:
                ForEach(viewModel.filteredSurahBookmarks) { bookmark in
                    AppSurahCard(
                        arabicName:  bookmark.arabicName,
                        englishName: bookmark.englishName,
                        ayahCount:   bookmark.ayahCount,
                        page:        bookmark.pageNumber,
                        action: { onNavigateToSurah?(bookmark.pageNumber) }
                    )
                    .swipeToRemove { viewModel.removeSurahBookmark(bookmark) }
                }

            case .ayah:
                ForEach(viewModel.filteredAyahBookmarks) { bookmark in
                    AppAyahCard(
                        arabicText:          bookmark.arabicText,
                        englishTranslation:  bookmark.translation,
                        surahName:           bookmark.surahName,
                        surahNumber:         bookmark.surahNumber,
                        ayahNumber:          bookmark.ayahNumber,
                        pageNumber:          bookmark.pageNumber,
                        fontName:            quranFontProvider?(bookmark.pageNumber),
                        action: { onNavigateToAyah?(bookmark.pageNumber, bookmark.ayahNumber) }
                    )
                    .swipeToRemove { viewModel.removeAyahBookmark(bookmark) }
                }

            case .page:
                ForEach(viewModel.filteredPageBookmarks) { bookmark in
                    PageBookmarkCard(
                        bookmark: bookmark,
                        action: { onNavigateToPage?(bookmark.pageNumber) }
                    )
                    .swipeToRemove { viewModel.removePageBookmark(bookmark) }
                }

            case .sheikh:
                ForEach(viewModel.filteredSheikhBookmarks) { bookmark in
                    SheikhBookmarkCard(
                        bookmark: bookmark,
                        action: { /* Sheikh navigation — not in scope */ }
                    )
                    .swipeToRemove { viewModel.removeSheikhBookmark(bookmark) }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        let hasSearch = !viewModel.searchText.isEmpty
        let (icon, title, message): (String, String, String) = {
            if hasSearch {
                return (
                    "magnifyingglass",
                    "No results found",
                    "No \(viewModel.selectedTab.title.lowercased()) bookmarks match \"\(viewModel.searchText)\"."
                )
            }
            switch viewModel.selectedTab {
            case .surah:  return ("bookmark", "No surah bookmarks yet",  "Long-press any word and tap \"Bookmark Surah\".")
            case .ayah:   return ("bookmark", "No ayah bookmarks yet",   "Long-press any word in the Mushaf and tap \"Bookmark Ayah\".")
            case .page:   return ("bookmark", "No page bookmarks yet",   "Tap the bookmark icon in the top bar while reading.")
            case .sheikh: return ("bookmark", "No sheikh bookmarks yet", "Reciters you bookmark will appear here.")
            }
        }()
        return BookmarkEmptyStateView(icon: icon, title: title, message: message)
    }
}

// MARK: - Row styling

private extension View {
    /// Strips List's default row chrome and adds a destructive swipe action.
    func swipeToRemove(action: @escaping () -> Void) -> some View {
        self
            .listRowInsets(EdgeInsets(top: DSSpacing.xs, leading: DSSpacing.md, bottom: DSSpacing.xs, trailing: DSSpacing.md))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive, action: action) {
                    Label("Remove", systemImage: "bookmark.slash")
                }
            }
    }
}
