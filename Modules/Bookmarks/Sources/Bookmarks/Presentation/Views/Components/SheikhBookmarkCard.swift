//
//  SheikhBookmarkCard.swift
//  Bookmarks (Presentation)
//
//  No shared component exists for this shape yet.
//

import SwiftUI
import Common
struct SheikhBookmarkCard: View {
    @Environment(\.dsColors) private var dsColors
    let bookmark: SheikhBookmark
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.smMd) {
                Circle()
                    .fill(dsColors.secondaryContainer)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(bookmark.name.prefix(1)))
                            .dsFont(DSTypography.titleMedium)
                            .foregroundColor(dsColors.onSecondaryContainer)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.name)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textPrimary)
                    Text("\(bookmark.arabicName) · \(bookmark.reciterStyle)")
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
