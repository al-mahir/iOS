//
//  CustomNavBar.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//
import SwiftUI
public struct CustomNavBar: View {
    @Binding public var selectedTab: TabItem
    @Environment(\.dsColors) private var dsColors
    
    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: DSSpacing.none) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                NavBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background(
            Capsule()
                .fill(dsColors.surface)
                .dsElevation(DSElevation.level3)
        )
        .padding(.horizontal, DSSpacing.lg)
        .padding(.bottom, DSSpacing.md)
    }
}
