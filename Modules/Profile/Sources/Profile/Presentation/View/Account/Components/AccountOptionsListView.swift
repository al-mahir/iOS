//
//  AccountOptionsListView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common
import Settings

struct AccountOptionsListView: View {
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showSettings = false

    @EnvironmentObject private var router: ProfileRouter
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            AccountOptionRow(title: "Settings", showChevron: true) {
                openSettings()
            }
            rowDivider

            AccountOptionRow(title: "Request a new feature", icon: "message")
            rowDivider

            AccountOptionRow(title: "Help center", icon: "questionmark.circle")
            rowDivider

            AccountOptionRow(title: "Share the app", icon: "square.and.arrow.up")
            rowDivider

            AccountOptionRow(title: "Rate the app", icon: "star")
            rowDivider

            AccountOptionRow(title: "Attributions", icon: "info.circle")
            rowDivider

            AccountOptionRow(title: "Privacy policy", showChevron: true) {
                showPrivacyPolicy = true
            }
            rowDivider

            AccountOptionRow(title: "Terms of service", showChevron: true) {
                showTermsOfService = true
            }
        }
        .padding(.vertical, DSSpacing.xs)
        .navigationDestination(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .navigationDestination(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
                .navigationBarBackButtonHidden(true)
        }
    }

    private func openSettings() {
        if !router.path.isEmpty || router.path.count > 0 {
            router.push(.settings)
        } else {
            showSettings = true
        }
    }

    private var rowDivider: some View {
        Divider()
            .background(dsColors.outlineVariant.opacity(0.3))
    }
}

#Preview {
    NavigationStack {
        AccountOptionsListView()
            .padding()
            .environmentObject(ProfileRouter())
            .dsTheme()
    }
}
