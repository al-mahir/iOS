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
struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        ZStack(alignment: .bottom) {
           
            Group {
                switch selectedTab {
                case .home:
                   HomeView()
                case .quran:
                   MushafRootView()
                case .bookmark:
                    Text("Bookmarks")
                case .profile:
                    Text("Profile")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(dsColors.surfaceContainerLowest)
            
            
            CustomNavBar(selectedTab: $selectedTab)
        }
    }
}
