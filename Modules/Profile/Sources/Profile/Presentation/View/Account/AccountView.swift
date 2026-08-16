//
//  AccountView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common
import Settings

public struct AccountView: View {
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    @State private var showMySubscriptions = false

    @EnvironmentObject private var router: ProfileRouter
    @Environment(\.dsColors) private var dsColors

    @ObservedObject private var sessionManager = SessionManager.shared
    @StateObject private var subscriptionsViewModel = MySubscriptionsViewModel()

    @MainActor
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: DSSpacing.lg) {

                    ProfileHeaderView(
                        username: sessionManager.currentUser?.fullName
                            ?? sessionManager.currentUser?.username,
                        email: sessionManager.currentUser?.email,
                        profilePictureUrl: sessionManager.currentUser?.profilePictureUrl,
                        joinedDate: formattedJoinedDate
                    )

                    AccountOptionRow(
                        title: "My Subscriptions",
                        showChevron: true,
                        badge: subscriptionsViewModel.activeCount > 0
                            ? LocalizedStringKey(
                                "\(subscriptionsViewModel.activeCount) active"
                            )
                            : nil
                    ) {
                        openMySubscriptions()
                    }

                    PremiumButtonView(
                        onSignOut: {
                            showLogoutAlert = true
                        }
                    )

                    SocialMediaLinksView()

                    AccountOptionsListView()
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, 90)
            }
        }
        .background(
            dsColors.background
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)

        .navigationDestination(
            isPresented: $showSettings
        ) {
            SettingsView()
                .navigationBarBackButtonHidden(true)
        }

        .navigationDestination(
            isPresented: $showMySubscriptions
        ) {
            MySubscriptionsView(
                viewModel: subscriptionsViewModel
            )
            .navigationBarBackButtonHidden(true)
        }

        .task {
            await subscriptionsViewModel.loadSubscriptions()
        }
        .onAppear {
            Task { await subscriptionsViewModel.loadSubscriptions() }
        }

        .dsTheme()

        .alert(
            String(
                localized: "Sign out",
                bundle: .module
            ),
            isPresented: $showLogoutAlert,
            actions: {

                Button(
                    String(
                        localized: "Cancel",
                        bundle: .module
                    ),
                    role: .cancel
                ) { }

                Button(
                    String(
                        localized: "Sign out",
                        bundle: .module
                    ),
                    role: .destructive
                ) {
                    NotificationCenter.default.post(
                        name: .appLogoutRequested,
                        object: nil
                    )
                }
            },
            message: {
                Text(
                    "Are you sure you want to sign out?",
                    bundle: .module
                )
            }
        )
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Profile", bundle: .module)
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, DSSpacing.mdLg)
        .padding(.vertical, DSSpacing.md)
        .background(
            dsColors.surfaceContainerLowest
        )
        .overlay(
            Rectangle()
                .fill(
                    dsColors.outlineVariant.opacity(0.3)
                )
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Navigation

    private func openSettings() {
        if !router.path.isEmpty || router.path.count > 0 {
            router.push(.settings)
        } else {
            showSettings = true
        }
    }

    private func openMySubscriptions() {
        showMySubscriptions = true
    }

    // MARK: - Joined Date

    private var formattedJoinedDate: String? {
        guard let date = sessionManager.currentUser?.createdAt else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return formatter.string(from: date)
    }
}
