//
//  TafsirPlaceholderView.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


import SwiftUI
import Common

/// Initial / onboarding state shown in the Tafsir tab when query is empty.
struct TafsirPlaceholderView: View {
    @Environment(\.dsColors) private var dsColors
    @State private var pulsate = false
    @State private var float = false

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            // Animated icon cluster
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.25))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulsate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulsate)

                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.45))
                    .frame(width: 100, height: 100)

                Image(systemName: "book.pages.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [dsColors.primary, dsColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: float ? -6 : 4)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: float)
            }
            .onAppear {
                pulsate = true
                float = true
            }

            // Title + description
            VStack(spacing: DSSpacing.sm) {
                Text("Explore Tafsir")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Search for a Surah by name or number\nto read the Ibn Kathir commentary.")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Example search hints
            VStack(spacing: DSSpacing.sm) {
                hintChip(icon: "1.square",           label: "Search \"Al-Fatiha\" or \"1\"")
                hintChip(icon: "text.magnifyingglass", label: "Search \"Al-Baqarah\" or \"2\"")
                hintChip(icon: "book.closed",          label: "Any Surah name or number")
            }
            .padding(.horizontal, DSSpacing.xl)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl)
    }

    private func hintChip(icon: String, label: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(dsColors.primary)
                .frame(width: 28)
            Text(label)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)
            Spacer()
            Image(systemName: "arrow.right")
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
