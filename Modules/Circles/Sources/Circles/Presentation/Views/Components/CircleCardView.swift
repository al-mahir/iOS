//
//  CircleCardView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct CircleCardView: View {
    @Environment(\.dsColors) private var dsColors
    public let circle: CircleModel
    public let onJoinTap: () -> Void

    public init(circle: CircleModel, onJoinTap: @escaping () -> Void) {
        self.circle = circle
        self.onJoinTap = onJoinTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                levelBadge
                
                Spacer()
                
                if circle.isLive {
                    liveBadge
                }
            }

            HStack(alignment: .top) {
                initialsAvatar
                
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(circle.name)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    HStack(spacing: DSSpacing.xs) {
                        Text(circle.sheikhName)
                            .dsFont(DSTypography.bodyMedium)
                            .foregroundColor(dsColors.textSecondary)

                        Text("•")
                            .foregroundColor(dsColors.textHint)

                        Text("Reading \(circle.capacityText)")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textHint)
                    }
                }
                
                Spacer()
            }

            HStack {
                Spacer()

                Button(action: onJoinTap) {
                    Text("Join")
                        .dsFont(DSTypography.buttonText)
                        .foregroundColor(dsColors.onPrimary)
                        .padding(.horizontal, DSSpacing.lg)
                        .padding(.vertical, DSSpacing.sm)
                        .background(dsColors.primary)
                        .cornerRadius(DSRadius.sm)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.md)
        .dsElevation(DSElevation.level1)
    }

    private var liveBadge: some View {
        HStack(spacing: 4) {
            Text("LIVE")
                .dsFont(DSTypography.badgeText)
                .foregroundColor(Color.red)
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xxs)
        .background(Color.red.opacity(0.12))
        .cornerRadius(DSRadius.full)
    }

    private var levelBadge: some View {
        Text(circle.level.title)
            .dsFont(DSTypography.badgeText)
            .foregroundColor(levelTextColor)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(levelBackgroundColor)
            .cornerRadius(DSRadius.full)
    }

    private var initialsAvatar: some View {
        ZStack {
            SwiftUI.Circle()
                .fill(dsColors.primaryContainer)
                .frame(width: 40, height: 40)

            Text(circle.sheikhInitials)
                .dsFont(DSTypography.labelLarge)
                .foregroundColor(dsColors.primary)
        }
    }

    private var levelTextColor: Color {
        switch circle.level {
        case .beginner:
            return dsColors.success
        case .intermediate:
            return dsColors.warning
        case .advanced:
            return dsColors.error
        }
    }

    private var levelBackgroundColor: Color {
        switch circle.level {
        case .beginner:
            return dsColors.success.opacity(0.15)
        case .intermediate:
            return dsColors.warning.opacity(0.15)
        case .advanced:
            return dsColors.error.opacity(0.15)
        }
    }
}
