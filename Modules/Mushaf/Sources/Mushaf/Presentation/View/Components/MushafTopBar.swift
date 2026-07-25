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
    let isBookmarked: Bool
    /// When non-nil a back-chevron button is shown on the leading edge so
    /// the user can return to the screen that launched the Mushaf (e.g. Bookmarks).
    let onDismiss: (() -> Void)?
    let onTapPageNumber: () -> Void
    let onTapBookmark: () -> Void
    let onTapSettings: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {

                // ── Leading: back button OR page-jump pill ────────────────
                if let onDismiss {
                    // Back button — shown when Mushaf was opened from Bookmarks (or any modal caller)
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Back")
                                .dsFont(DSTypography.labelLarge)
                        }
                        .foregroundColor(dsColors.primary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(Capsule().fill(dsColors.primaryContainer))
                    }
                } else {
                    Button(action: onTapPageNumber) {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Page \(pageNumber)")
                                .dsFont(DSTypography.labelLarge)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(dsColors.textSecondary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(Capsule().fill(dsColors.surfaceContainerLow))
                    }
                }

                Spacer()

                // ── Trailing: page number (when back is shown) + controls ─
                if onDismiss != nil {
                    Button(action: onTapPageNumber) {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Page \(pageNumber)")
                                .dsFont(DSTypography.labelLarge)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(dsColors.textSecondary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .background(Capsule().fill(dsColors.surfaceContainerLow))
                    }
                }

                HStack(spacing: DSSpacing.sm) {
                    iconButton(isBookmarked ? "bookmark-filled" : "bookmark", action: onTapBookmark)
                    iconButton("settings", action: onTapSettings)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.sm)
        .background(dsColors.surfaceContainer)
    }

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
}

