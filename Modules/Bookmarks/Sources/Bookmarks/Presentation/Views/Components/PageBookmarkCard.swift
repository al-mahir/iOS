//
//  PageBookmarkCard.swift
//  Bookmarks (Presentation)
//

import SwiftUI
import Common

struct PageBookmarkCard: View {
    @Environment(\.dsColors) private var dsColors

    let bookmark: PageBookmark
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.smMd) {
                ZStack {
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(dsColors.primaryContainer)
                        .frame(width: 44, height: 44)

                    Text("\(bookmark.pageNumber)")
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.onPrimaryContainer)
                }

                VStack(alignment: .leading, spacing: 2) {
                    let pageTextFormat =
                        LanguageManager.localizedString(
                            "bookmark.page.format",
                            bundle: .module
                        )

                    Text(
                        String(
                            format: pageTextFormat,
                            bookmark.pageNumber
                        )
                    )
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)

                    let juzTextFormat =
                        LanguageManager.localizedString(
                            "bookmark.juz.format",
                            bundle: .module
                        )

                    let juzString = String(
                        format: juzTextFormat,
                        bookmark.juzNumber
                    )

                    Text("\(bookmark.surahName) · \(juzString)")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(dsColors.surfaceContainerLow)
            )
        }
        .buttonStyle(.plain)
    }
}
