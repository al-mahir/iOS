//
//  SheikhSegmentedTabBar.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhSegmentedTabBar: View {
    @Binding var selectedTab: SheikhTab
    @Environment(\.dsColors) private var dsColors

    public init(selectedTab: Binding<SheikhTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            HStack(spacing: DSSpacing.none) {
                ForEach(SheikhTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: DSSpacing.xs) {
                            Text(LocalizedStringKey(tab.titleEn), bundle: .module)
                                .dsFont(selectedTab == tab ? DSTypography.titleSmall : DSTypography.bodyMedium)
                                .foregroundColor(selectedTab == tab ? dsColors.primary : dsColors.textSecondary)
                                .fontWeight(selectedTab == tab ? .bold : .medium)

                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)

                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(dsColors.primary)
                                        .frame(height: 3)
                                        .matchedGeometryEffect(id: "underline", in: namespace)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .foregroundColor(dsColors.outlineVariant.opacity(0.5))
        }
        .background(dsColors.background)
    }

    @Namespace private var namespace
}
