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
    @EnvironmentObject private var router: ProfileRouter
    @Environment(\.dsColors) private var dsColors

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: DSSpacing.lg) {

                    ProfileHeaderView()

                    PremiumButtonView()

                    SocialMediaLinksView()

                    AccountOptionsListView()

                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, 90)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
                .navigationBarBackButtonHidden(true)
        }
        .dsTheme()
    }

    private var header: some View {
        ZStack {
            Text("Profile")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer()

                Button(action: openSettings) {
                    Circle()
                        .fill(dsColors.surfaceContainerLowest)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(dsColors.textPrimary)
                        )
                        .overlay(
                            Circle().stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: dsColors.shadow.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, DSSpacing.mdLg)
        .padding(.vertical, DSSpacing.md)
        .background(dsColors.surfaceContainerLowest)
        .overlay(
            Rectangle()
                .fill(dsColors.outlineVariant.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func openSettings() {
        if !router.path.isEmpty || router.path.count > 0 {
            router.push(.settings)
        } else {
            showSettings = true
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject(ProfileRouter())
    }
}
