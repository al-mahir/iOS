//
//  MushafTopBar.swift
//  Mushaf
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI
import Common

struct MushafTopBar: View {
    @Environment(\.dsColors) private var dsColors

    let pageNumber: Int
    let juzNumber: Int
    let surahName: String
    let onDismiss: (() -> Void)?
    let onTapNavigate: () -> Void
    let onTapSearch: () -> Void
    let onTapSettings: () -> Void
    let onTapMenu: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {

            // ── Leading: back button OR settings + search ─────────────
            if let onDismiss {
                iconButton(systemName: "chevron.left", action: onDismiss)
            } else {
                HStack(spacing: DSSpacing.sm) {
                    iconButton("settings", action: onTapSettings)
                    iconButton(systemName: "magnifyingglass", action: onTapSearch)
                }
            }

            // ── Center: tappable pill — surah name + page/juz ──────────
            Button(action: onTapNavigate) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(surahName)
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)

                    Text("Page \(pageNumber) • Juz \(juzNumber)")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(dsColors.surfaceContainerLow)
                )
            }
            .buttonStyle(.plain)

            // ── Trailing: menu ──────────────────────────────────────────
            iconButton(systemName: "line.3.horizontal", action: onTapMenu)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.sm)
        .background(dsColors.surfaceContainer)
    }

    // MARK: - Icon buttons

    /// Custom asset icon (from the design-system bundle), e.g. "settings".
    private func iconButton(_ imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(imageName, bundle: .common)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 24, height: 24)
                .frame(width: 32, height: 32)
                .background(Circle().fill(dsColors.surfaceContainerLow))
        }
    }

    /// SF Symbol icon — used where no dedicated design-system asset exists yet.
    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(dsColors.surfaceContainerLow))
        }
    }
}
