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
    let isPageBookmarked: Bool
    let onDismiss: (() -> Void)?
    let onTapNavigate: () -> Void
    let onTapSearch: () -> Void
    let onTapSettings: () -> Void
    let onTapMenu: () -> Void
    let onTapBookmarkPage: () -> Void

    private var localizedSubtitle: String {
        String(
            localized: "Page \(pageNumber) • Juz \(juzNumber)",
            bundle: .module,
            comment: "Subtitle displaying current page and juz numbers"
        )
    }

    var body: some View {
        HStack(spacing: DSSpacing.sm) {

            if let onDismiss {
                iconButton(systemName: "chevron.backward", action: onDismiss)
            } else {
                HStack(spacing: DSSpacing.xs) {
                    iconButton("settings", action: onTapSettings)
                    iconButton(systemName: "magnifyingglass", action: onTapSearch)
                }
            }

            Button(action: onTapNavigate) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(surahName)
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)

                    Text(localizedSubtitle)
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

            // Page bookmark button
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onTapBookmarkPage()
            }) {
                Image(systemName: isPageBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isPageBookmarked ? dsColors.primary : dsColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(isPageBookmarked ? dsColors.primaryContainer : dsColors.surfaceContainerLow))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPageBookmarked)
            }
            .frame(minWidth: 44, minHeight: 44)

            iconButton(systemName: "line.3.horizontal", action: onTapMenu)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.sm)
        .background(dsColors.surfaceContainer)
    }

    // MARK: - Icon buttons

    private func iconButton(_ imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(imageName, bundle: .common)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 18, height: 18)
                .frame(width: 36, height: 36)
                .background(Circle().fill(dsColors.surfaceContainerLow))
        }
        .frame(minWidth: 44, minHeight: 44)
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 36, height: 36)
                .background(Circle().fill(dsColors.surfaceContainerLow))
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}
