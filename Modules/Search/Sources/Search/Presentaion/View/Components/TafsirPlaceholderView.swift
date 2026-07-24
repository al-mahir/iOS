//
//  TafsirPlaceholderView.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


//
//  TafsirPlaceholderView.swift
//  Search
//
//  Created on 23/07/2026.
//

import SwiftUI
import Common

/// Beautiful placeholder shown in the Tafsir tab until the feature is implemented.
struct TafsirPlaceholderView: View {
    @Environment(\.dsColors) private var dsColors
    @State private var pulsate = false
    @State private var rotate = false

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            // Animated icon
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulsate ? 1.15 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulsate)

                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.5))
                    .frame(width: 90, height: 90)

                Image(systemName: "book.pages.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [dsColors.primary, dsColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(rotate ? 5 : -5))
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: rotate)
            }
            .onAppear {
                pulsate = true
                rotate = true
            }

            VStack(spacing: DSSpacing.sm) {
                Text("Tafsir Coming Soon")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("In-depth Quranic commentary and\nexplanations are on the way.")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Feature preview chips
            VStack(spacing: DSSpacing.sm) {
                featureChip(icon: "scroll.fill",       label: "Classical Tafsir sources")
                featureChip(icon: "lightbulb.fill",    label: "Summary commentary")
                featureChip(icon: "person.fill",       label: "Scholar explanations")
            }
            .padding(.horizontal, DSSpacing.xl)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl)
    }

    private func featureChip(icon: String, label: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(dsColors.primary)
                .frame(width: 28)
            Text(label)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)
            Spacer()
            Image(systemName: "clock")
                .font(.system(size: 12))
                .foregroundColor(dsColors.textHint)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
