//
//  BookmarkSearchField.swift
//  Bookmarks (Presentation)
//

import SwiftUI
import Common

struct BookmarkSearchField: View {
    @Environment(\.dsColors) private var dsColors

    @Binding var text: String

    @MainActor
    private var placeholder: String {
        LanguageManager.localizedString(
            "bookmark.search.placeholder",
            bundle: .module
        )
    }

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textTertiary)

            TextField(
                placeholder,
                text: $text
            )
            .dsFont(DSTypography.bodyMedium)
            .foregroundColor(dsColors.textPrimary)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(dsColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.smMd)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
