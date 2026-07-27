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
    var subscriptionStatus: String = "None"
    var joinedDate: String = "Unknown"

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            HStack(spacing: DSSpacing.md) {
                // Circle Initials Avatar
                ZStack {
                    Circle()
                        .stroke(dsColors.primary, lineWidth: 2)
                        .background(Circle().fill(dsColors.surfaceContainerLowest))
                        .frame(width: 64, height: 64)

                    Text(initials)
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(username ?? "Guest")
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    if let email = email, !email.isEmpty {
                        Text(email)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }

                Spacer()
            }

            VStack(spacing: DSSpacing.xxs) {
                HStack {
                    Text("Subscription status")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)

                    Spacer()

                    Text("Joined")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }

                HStack {
                    Text(subscriptionStatus)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)

                    Spacer()

                    Text(joinedDate)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                }
            }
        }
        .padding(DSSpacing.md)
    }

    private var initials: String {
        let nameToUse = username ?? "Guest"
        let components = nameToUse.components(separatedBy: " ")
        if components.count >= 2, let first = components[0].first, let second = components[1].first {
            return "\(first)\(second)".lowercased()
        } else if let first = nameToUse.first {
            if nameToUse.count >= 2 {
                let second = nameToUse[nameToUse.index(nameToUse.startIndex, offsetBy: 1)]
                return "\(first)\(second)".lowercased()
            }
            return String(first).lowercased()
        }
        return "gu"
    }
}

#Preview {
    ProfileHeaderView()
        .dsTheme()
}
