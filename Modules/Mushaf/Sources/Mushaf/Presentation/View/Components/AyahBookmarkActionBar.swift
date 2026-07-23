//
//  AyahBookmarkActionBar.swift
//  Mushaf
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//

import SwiftUI
import Common

/// Floating action bar that appears when the user long-presses a word.
/// Lets them bookmark the selected ayah OR the whole surah from anywhere on
/// the page — including the middle of a surah where the banner isn't visible.
///
/// Auto-dismisses after 5 seconds of inactivity (the `.task` is automatically
/// cancelled by SwiftUI if the view disappears before the timer fires).
struct AyahBookmarkActionBar: View {
    @Environment(\.dsColors) private var dsColors

    let surahNumber: Int
    let ayahNumber: Int
    let isAyahBookmarked: Bool
    let isSurahBookmarked: Bool
    let onBookmarkAyah: () -> Void
    let onBookmarkSurah: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // ── Info row ─────────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ayah \(ayahNumber)")
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.textPrimary)
                    Text(SurahNames.name(for: surahNumber))
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textTertiary)
                }

                Spacer()

                // Dismiss ×
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(dsColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(dsColors.surfaceContainerLow))
                }
            }

            Divider()
                .background(dsColors.outlineVariant)

            // ── Action row ───────────────────────────────────────────────
            HStack(spacing: DSSpacing.sm) {
                // Bookmark Ayah
                bookmarkButton(
                    icon: isAyahBookmarked ? "bookmark.fill" : "bookmark",
                    label: isAyahBookmarked ? "Ayah Saved" : "Bookmark Ayah",
                    isActive: isAyahBookmarked,
                    action: onBookmarkAyah
                )

                // Bookmark Surah
                bookmarkButton(
                    icon: isSurahBookmarked ? "books.vertical.fill" : "books.vertical",
                    label: isSurahBookmarked ? "Surah Saved" : "Bookmark Surah",
                    isActive: isSurahBookmarked,
                    action: onBookmarkSurah
                )
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainer)
                .shadow(color: dsColors.shadow.opacity(0.18), radius: 12, y: 4)
        )
        // Auto-dismiss after 5 s. The task is cancelled automatically when the
        // view leaves the hierarchy (i.e. the user already dismissed it).
        .task {
            try? await Task.sleep(for: .seconds(5))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) { onDismiss() }
            }
        }
    }

    // MARK: - Button helper

    @ViewBuilder
    private func bookmarkButton(
        icon: String,
        label: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .dsFont(DSTypography.labelMedium)
            }
            .foregroundColor(isActive ? dsColors.primary : dsColors.onPrimary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isActive ? dsColors.primaryContainer : dsColors.primary)
            )
        }
    }
}

