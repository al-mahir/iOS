//
//  BookmarkEmptyStateView.swift
//  Bookmarks (Presentation)
//

import SwiftUI
import Common
struct BookmarkEmptyStateView: View {
    @Environment(\.dsColors) private var dsColors
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: DSSpacing.smMd) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(dsColors.textTertiary)
            Text(title)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.top, DSSpacing.xl3)
        .frame(maxWidth: .infinity)
    }
}
