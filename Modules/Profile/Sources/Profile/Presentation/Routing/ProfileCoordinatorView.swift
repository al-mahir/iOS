//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import SwiftUI
import Settings

public struct ProfileCoordinatorView: View {
    @StateObject private var router: ProfileRouter
    private let profileViewModel: ProfileStatsViewModel
    
    public init(router: ProfileRouter, viewModel: ProfileStatsViewModel) {
        _router = StateObject(wrappedValue: router)
        self.profileViewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            ProfileActivityView(viewModel: profileViewModel)
                .navigationBarHidden(true)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .account:
                        AccountView()
                            .navigationTitle("My Account")
                            .navigationBarTitleDisplayMode(.inline)
                    case .settings:
                        SettingsView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .environmentObject(router)
        }
    }
}
