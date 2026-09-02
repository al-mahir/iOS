//
//  SheikhCard.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import SwiftUI
import Common
import Sheikh

struct SheikhCard: View {
    @Environment(\.dsColors) private var dsColors
    let sheikh: Sheikh

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            ZStack {
                if let urlStr = sheikh.profilePictureUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                        } else {
                            initialsCircle
                        }
                    }
                } else {
                    initialsCircle
                }
            }

            Text(sheikh.fullName)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .lineLimit(1)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(dsColors.warning)
                Text(String(format: "%.1f", sheikh.rate))
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(sheikh.isAvailable ? dsColors.success : dsColors.error)
                    .frame(width: 6, height: 6)
                Text(sheikh.sheikhStatus.localizedTitle)
                    .dsFont(DSTypography.caption)
                    .foregroundColor(dsColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(DSSpacing.md)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(dsColors.outlineVariant, lineWidth: 1)
        )
    }

    private var initialsCircle: some View {
        Circle()
            .fill(dsColors.primary)
            .frame(width: 56, height: 56)
            .overlay(
                Text(sheikh.initials)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.onPrimary)
            )
    }
}
