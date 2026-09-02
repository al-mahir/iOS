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
        VStack(spacing: DSSpacing.lg) {
            optionCardGroup(title: "SETTINGS & PREFERENCES") {
                VStack(spacing: 0) {
                    AccountOptionRow(title: "Settings", icon: "gearshape", showChevron: true) {
                        openSettings()
                    }
                }
            }

            optionCardGroup(title: "HELP & SUPPORT") {
                VStack(spacing: 0) {
                    AccountOptionRow(title: "Request a new feature", icon: "bubble.left")
                    groupDivider
                    AccountOptionRow(title: "Help center", icon: "questionmark.circle")
                    groupDivider
                    AccountOptionRow(title: "Share the app", icon: "square.and.arrow.up")
                    groupDivider
                    AccountOptionRow(title: "Rate the app", icon: "star")
                }
            }

            optionCardGroup(title: "ABOUT") {
                VStack(spacing: 0) {
                    AccountOptionRow(title: "Attributions", icon: "info.circle")
                    groupDivider
                    AccountOptionRow(title: "Privacy policy", icon: "lock.shield", showChevron: true) {
                        showPrivacyPolicy = true
                    }
                    groupDivider
                    AccountOptionRow(title: "Terms of service", icon: "doc.text", showChevron: true) {
                        showTermsOfService = true
                    }
                }
            }
        }
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

    private func optionCardGroup<Content: View>(title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title, bundle: .module)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textSecondary)
                .padding(.horizontal, DSSpacing.xs)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .fill(dsColors.surfaceContainerLowest)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
            )
        }
    }

    private func openSettings() {
        if !router.path.isEmpty || router.path.count > 0 {
            router.push(.settings)
        } else {
            showSettings = true
        }
    }

    private var groupDivider: some View {
        Divider()
            .padding(.leading, 50)
            .background(dsColors.outlineVariant.opacity(0.2))
    }
}
