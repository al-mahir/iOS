//
//  BookmarkTabPicker.swift
//  Bookmarks (Presentation)
//

import SwiftUI
import Common
struct BookmarkTabPicker: View {
    @Environment(\.dsColors) private var dsColors
    @Binding var selectedTab: BookmarkTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(BookmarkTab.allCases) { tab in
                    let isSelected = tab == selectedTab
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { selectedTab = tab }
                    } label: {
                        Text(tab.title)
                            .dsFont(DSTypography.labelLarge)
                            .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                Capsule().fill(isSelected ? dsColors.primary : dsColors.surfaceContainerLow)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
