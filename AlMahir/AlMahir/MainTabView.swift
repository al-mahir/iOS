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
import Profile

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @Environment(\.dsColors) private var dsColors
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .bookmark:
                    Text("Bookmarks")
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
    }
}
