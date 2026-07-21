//
//  SheikhCard.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//



import SwiftUI
import Common

struct SheikhCard: View {
    @Environment(\.dsColors) private var dsColors
    let sheikh: SheikhEntity

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Circle()
                .fill(dsColors.primary)
                .frame(width: 56, height: 56)
                .overlay(
                    Text(sheikh.initial)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.onPrimary)
                )

            Text(sheikh.name)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .lineLimit(1)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(dsColors.warning)
                Text(String(format: "%.1f", sheikh.rating))
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(sheikh.isInSession ? dsColors.error : dsColors.success)
                    .frame(width: 6, height: 6)
                Text(sheikh.isInSession ? "In Session" : "Available")
                    .dsFont(DSTypography.caption)
                    .foregroundColor(dsColors.textTertiary)
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
}
