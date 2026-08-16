//
//  SheikhProfileHeaderView.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhProfileHeaderView: View {
    let sheikh: Sheikh
    let onBackTap: () -> Void
    let onFavoriteTap: () -> Void

    @Environment(\.dsColors) private var dsColors

    public init(
        sheikh: Sheikh,
        onBackTap: @escaping () -> Void,
        onFavoriteTap: @escaping () -> Void
    ) {
        self.sheikh = sheikh
        self.onBackTap = onBackTap
        self.onFavoriteTap = onFavoriteTap
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            // Top App Bar
            HStack {
                Button(action: onBackTap) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                        .padding(DSSpacing.sm)
                        .background(
                            Circle()
                                .fill(dsColors.surface.opacity(0.8))
                        )
                }

                Spacer()

                Button(action: onFavoriteTap) {
                    Image(systemName: sheikh.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(sheikh.isFavorite ? Color.red : dsColors.primary)
                        .padding(DSSpacing.sm)
                        .background(
                            Circle()
                                .fill(dsColors.surface.opacity(0.8))
                        )
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.sm)

            // Centered Profile Avatar & Information
            VStack(spacing: DSSpacing.sm) {
                // Profile Avatar (100x100)
                ZStack {
                    Circle()
                        .fill(dsColors.primary)
                        .frame(width: 100, height: 100)

                    Text(sheikh.initials)
                        .dsFont(DSTypography.headlineMedium)
                        .foregroundColor(dsColors.onPrimary)
                }
                .dsElevation(DSElevation.level2)
                .padding(.top, DSSpacing.xs)

                // Name & Verified Badge
                HStack(spacing: DSSpacing.xs) {
                    Text(sheikh.fullName)
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)

                    if sheikh.hasVerifiedIjazah {
                        verifiedBadge
                    }
                }

                // Status Pill
                statusPill(sheikh.sheikhStatus)
            }
            .padding(.bottom, DSSpacing.md)
        }
        .background(
            LinearGradient(
                colors: [
                    dsColors.primaryContainer.opacity(0.4),
                    dsColors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var verifiedBadge: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 11))
                .foregroundColor(dsColors.primary)

            Text("IJAZAH")
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.primary)
                .fontWeight(.bold)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .stroke(dsColors.primary.opacity(0.4), lineWidth: 1)
                .background(Capsule().fill(dsColors.primaryContainer.opacity(0.5)))
        )
    }

    private func statusPill(_ status: SheikhAvailabilityStatus) -> some View {
        let color: Color
        switch status {
        case .available:
            color = dsColors.success
        case .notAvailable:
            color = dsColors.error
        case .pendingApproval:
            color = dsColors.warning
        }

        return HStack(spacing: DSSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(status.displayTitle)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(DSInteractionOpacity.pressed))
        )
    }
}
