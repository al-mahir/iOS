//
//  MainTabView.swift
//  AlMahir
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI
import Mushaf
import Common
import Search
import Home
import Bookmarks
import Profile

// MARK: - Navigation destination


struct MushafNavDestination: Identifiable {
    let id = UUID()
    let page: Int
    let targetAyah: Int?
}

// MARK: - MainTabView

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var tabBarVisibility = TabBarVisibility()
    /// Stable container — created once, not on every tab switch.
    @StateObject private var bookmarksContainer = BookmarksDependencyContainer()
    /// Non-nil when a bookmark tap requests Mushaf navigation.
    @State private var mushafDestination: MushafNavDestination? = nil

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()

//                case .bookmark:
//                    BookmarksView(
//                        container: bookmarksContainer,
//                 
//                        quranFontProvider: { page in
//                            MushafFontManager.shared.fontName(forPage: page, set: .plain)
//                        },
//                    
//                        onNavigateToPage: { page in
//                            mushafDestination = MushafNavDestination(page: page, targetAyah: nil)
//                        },
//                       
//                        onNavigateToAyah: { page, ayah in
//                            mushafDestination = MushafNavDestination(page: page, targetAyah: ayah)
//                        },
//                       
//                        onNavigateToSurah: { startPage in
//                            mushafDestination = MushafNavDestination(page: startPage, targetAyah: nil)
//                        }
//                    )

                case .profile:
                    if let profileCoordinator = AppDIContainer.shared.resolve(ProfileCoordinatorView.self) {
                        profileCoordinator
                    } else {
                        Text("Error Loading Profile")
                            .foregroundColor(.red)
                    }

                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(dsColors.surfaceContainerLowest)
            .environment(\.tabBarVisibility, tabBarVisibility)

            if tabBarVisibility.isVisible {
                CustomNavBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: tabBarVisibility.isVisible)
        // Full-screen Mushaf presented on any bookmark tap.
        .fullScreenCover(item: $mushafDestination) { destination in
            MushafRootView(
                startPage: destination.page,
                targetAyahNumber: destination.targetAyah,
                showBackButton: true
            )
        }
    }
}

