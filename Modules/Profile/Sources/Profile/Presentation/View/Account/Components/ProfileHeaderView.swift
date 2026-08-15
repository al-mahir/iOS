//
//  ProfileHeaderView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common

struct ProfileHeaderView: View {
    var username: String?
    var email: String?
    var profilePictureUrl: String?
    var subscriptionStatus: String?
    var joinedDate: String?

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.md) {

            // MARK: - User Meta Header Row

            HStack(spacing: DSSpacing.md) {
                // Circle Initials Avatar
                ZStack {
                    Circle()
                        .fill(dsColors.primary.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(
                                    dsColors.primary.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                        .frame(width: 60, height: 60)

                    Text(initials)
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {

                    // Guest must remain a localized SwiftUI Text
                    if let username, !username.isEmpty {
                        Text(username)
                            .dsFont(DSTypography.titleMedium)
                            .foregroundColor(dsColors.textPrimary)
                    } else {
                        Text("Guest", bundle: .module)
                            .dsFont(DSTypography.titleMedium)
                            .foregroundColor(dsColors.textPrimary)
                    }

                    if let email = email, !email.isEmpty {
                        Text(email)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }

                Spacer()
            }

            Divider()
                .background(dsColors.outlineVariant.opacity(0.3))

            // MARK: - Footer Quick Stats Row

            HStack(spacing: DSSpacing.xs) {

                statTile(
                    label: "App Premium",
                    value: subscriptionStatus
                )

                Divider()
                    .frame(height: 24)
                    .background(
                        dsColors.outlineVariant.opacity(0.3)
                    )

                statTile(
                    label: "Joined",
                    value: joinedDate
                )
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(
                cornerRadius: DSRadius.lg,
                style: .continuous
            )
            .fill(dsColors.surfaceContainerLowest)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: DSRadius.lg,
                style: .continuous
            )
            .stroke(
                dsColors.outlineVariant.opacity(0.3),
                lineWidth: 1
            )
        )
    }

    // MARK: - Stat Tile

    private func statTile(
        label: LocalizedStringKey,
        value: String?
    ) -> some View {
        VStack(spacing: DSSpacing.xxs) {

            Text(label, bundle: .module)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textSecondary)

            if let value, !value.isEmpty {
                Text(value)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
            } else {
                Text("None", bundle: .module)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Initials

    private var initials: String {
        guard let username, !username.isEmpty else {
            return "GU"
        }

        let components = username.components(
            separatedBy: " "
        )

        if components.count >= 2,
           let first = components[0].first,
           let second = components[1].first {
            return "\(first)\(second)".uppercased()
        }

        if let first = username.first {
            return String(first).uppercased()
        }

        return "GU"
    }
}
