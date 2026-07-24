//
//  SheikhCard.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//
//hello I want to rebuild  ui
//I will send you screenshots for current and needed view
//first I want to change the fixed card
//make it with segment to change modes like needed image and contain eye for view or hide the text in the view and fab when click open sheet of tagweed colors
//and when click on the screen hide the all components keeps only the Quran text like in needed3 image
//reading mode is the normal view of mashuf and listening like needed2  image
//and when click on an ayah long press open sheet contain tafsser text
// for the design of the top bar
//make it like needed 4 image without the present icon


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
