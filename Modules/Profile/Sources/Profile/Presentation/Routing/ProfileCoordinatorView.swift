//
//  ProfileCoordinatorView.swift
//  Profile
//
//  Created by Esraa Ehab on 21/07/2026.
//

import SwiftUI
import Settings
import Common

public struct ProfileCoordinatorView: View {
    @StateObject private var router: ProfileRouter
    private let profileViewModel: ProfileStatsViewModel

    public init(router: ProfileRouter, viewModel: ProfileStatsViewModel) {
        _router = StateObject(wrappedValue: router)
        self.profileViewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            AccountView()
                .navigationBarHidden(true)
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .account:
                        AccountView()
                    case .settings:
                        SettingsView()
                            .navigationBarBackButtonHidden(true)
                    case .activity:
                        ProfileActivityView(viewModel: profileViewModel)
                            .navigationBarHidden(true)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .environmentObject(router)
        }
    }
}
