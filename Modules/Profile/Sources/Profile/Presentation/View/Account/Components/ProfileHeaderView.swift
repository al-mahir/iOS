//
//  ProfileHeaderView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common

struct ProfileHeaderView: View {
    var username: String = "alaaayman"
    var email: String = "alaaaymanfoaud@gmail.com"
    var subscriptionStatus: String = "None"
    var joinedDate: String = "7/14/26"

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
                    Text(username)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    Text(email)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
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
        let components = username.components(separatedBy: " ")
        if components.count >= 2, let first = components[0].first, let second = components[1].first {
            return "\(first)\(second)".lowercased()
        } else if let first = username.first {
            if username.count >= 2 {
                let second = username[username.index(username.startIndex, offsetBy: 1)]
                return "\(first)\(second)".lowercased()
            }
            return String(first).lowercased()
        }
        return "aa"
    }
}

#Preview {
    ProfileHeaderView()
        .dsTheme()
}
