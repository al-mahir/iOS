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
    /// the Mushaf or Sheikh detail.
    private let onNavigateToPage: ((Int) -> Void)?
    private let onNavigateToAyah: ((Int, Int) -> Void)?   // (pageNumber, ayahNumber)
    private let onNavigateToSurah: ((Int) -> Void)?       // startPage
    private let onNavigateToSheikh: ((String) -> Void)?   // sheikhID

    // MARK: - Init

    public init(
        container: BookmarksDependencyContainer,
        quranFontProvider: ((Int) -> String?)? = nil,
        onNavigateToPage: ((Int) -> Void)? = nil,
        onNavigateToAyah: ((Int, Int) -> Void)? = nil,
        onNavigateToSurah: ((Int) -> Void)? = nil,
        onNavigateToSheikh: ((String) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: container.makeBookmarksViewModel())
        self.quranFontProvider  = quranFontProvider
        self.onNavigateToPage   = onNavigateToPage
        self.onNavigateToAyah   = onNavigateToAyah
        self.onNavigateToSurah  = onNavigateToSurah
        self.onNavigateToSheikh = onNavigateToSheikh
    }

    // MARK: - Body

    @State private var sheikhToRemove: SheikhBookmark? = nil

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
        .alert("Remove Bookmark?", isPresented: Binding(
            get: { sheikhToRemove != nil },
            set: { if !$0 { sheikhToRemove = nil } }
        ), presenting: sheikhToRemove) { bookmark in
            Button("Remove", role: .destructive) {
                viewModel.removeSheikhBookmark(bookmark)
                sheikhToRemove = nil
            }
            Button("Cancel", role: .cancel) {
                sheikhToRemove = nil
            }
        } message: { bookmark in
            Text("Are you sure you want to remove \(bookmark.name) from your bookmarks?")
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
                    let startPage = Self.surahStartPages[safe: bookmark.surahNumber - 1] ?? bookmark.pageNumber
                    AppSurahCard(
                        surahNumber: bookmark.surahNumber,
                        arabicName:  bookmark.arabicName,
                        englishName: bookmark.englishName,
                        ayahCount:   bookmark.ayahCount,
                        page:        startPage,
                        action: { onNavigateToSurah?(startPage) }
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
                        action: { onNavigateToSheikh?(bookmark.sheikhID) }
                    )
                    .swipeToRemove { sheikhToRemove = bookmark }
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

    private static let surahStartPages: [Int] = [
        1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
        221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
        322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
        411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
        477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
        520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
        551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
        570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
        586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
        595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
        600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
        603, 604, 604, 604
    ]
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
