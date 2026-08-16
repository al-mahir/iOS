//
//  MainTabView.swift
//  AlMahir
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI
import Mushaf
import Listening
import Common
import Search
import Home
import Bookmarks
import Profile
import Mualem
import Sheikh

// MARK: - Navigation destination

struct MushafNavDestination: Identifiable {
    let id = UUID()
    let page: Int
    let targetAyah: Int?
}

struct SheikhNavDestination: Identifiable {
    let id = UUID()
    let sheikhID: String
}

// MARK: - MainTabView

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var tabBarVisibility = TabBarVisibility()
    /// Shared listening ViewModel for global audio playback banner
    @StateObject private var listeningVM = ListeningDIContainer.shared.resolve(ListeningViewModel.self)
    /// Stable container — created once, not on every tab switch.
    @StateObject private var bookmarksContainer = BookmarksDependencyContainer()
    /// Non-nil when a bookmark tap requests Mushaf navigation.
    @State private var mushafDestination: MushafNavDestination? = nil
    /// Non-nil when a sheikh bookmark tap requests Sheikh detail navigation.
    @State private var sheikhDestination: SheikhNavDestination? = nil

    @State private var isShowingMuallim = false
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        onMuallemTapped: {
                            isShowingMuallim = true
                        }
                    )

                case .bookmark:
                    BookmarksView(
                        container: bookmarksContainer,
                        quranFontProvider: { page in
                            MushafFontManager.shared.fontName(forPage: page, set: .plain)
                        },
                        onNavigateToPage: { page in
                            mushafDestination = MushafNavDestination(page: page, targetAyah: nil)
                        },
                        onNavigateToAyah: { page, ayah in
                            mushafDestination = MushafNavDestination(page: page, targetAyah: ayah)
                        },
                        onNavigateToSurah: { startPage in
                            mushafDestination = MushafNavDestination(page: startPage, targetAyah: nil)
                        },
                        onNavigateToSheikh: { sheikhID in
                            sheikhDestination = SheikhNavDestination(sheikhID: sheikhID)
                        }
                    )

                case .profile:
                    if let profileCoordinator = AppDIContainer.shared.resolve(ProfileCoordinatorView.self) {
                        profileCoordinator
                    } else {
                        Text("Error Loading Profile", bundle: CommonBundle.bundle)
                            .foregroundColor(.red)
                    }

                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(dsColors.surfaceContainerLowest)
            .environment(\.tabBarVisibility, tabBarVisibility)

            VStack(spacing: DSSpacing.xs) {
                if listeningVM.isListeningModeActive && tabBarVisibility.isVisible && mushafDestination == nil && !isShowingMuallim {
                    GlobalAudioBanner(
                        viewModel: listeningVM,
                        onTapBanner: {
                            mushafDestination = MushafNavDestination(page: listeningVM.currentChapterStartPage, targetAyah: nil)
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if tabBarVisibility.isVisible {
                    CustomNavBar(selectedTab: $selectedTab)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: tabBarVisibility.isVisible)
        .animation(.easeInOut(duration: 0.25), value: listeningVM.isListeningModeActive)
        // Full-screen Mushaf presented on any bookmark tap.
        .fullScreenCover(item: $mushafDestination) { destination in
            MushafRootView(
                startPage: destination.page,
                targetAyahNumber: destination.targetAyah,
                showBackButton: true,
                onMuallemTapped: {
                    isShowingMuallim = true
                }
            )
        }
        .fullScreenCover(item: $sheikhDestination) { destination in
            SheikhDetailView(sheikhID: destination.sheikhID)
                .dsTheme()
        }
        .fullScreenCover(isPresented: $isShowingMuallim) {
            if let viewModel = AppDIContainer.shared.resolve(Mualem.MuallimViewModel.self) {
                Mualem.MuallimRootView(viewModel: viewModel)
            } else {
                Text("Error Loading Mu'allim", bundle: CommonBundle.bundle)
            }
        }
    }
}
