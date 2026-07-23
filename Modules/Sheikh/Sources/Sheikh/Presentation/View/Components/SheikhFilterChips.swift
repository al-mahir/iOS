//
//  SheikhFilterChips.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhFilterChips: View {

    @Binding public var selected: SheikhFilter
    @Environment(\.dsColors) private var dsColors

    public init(selected: Binding<SheikhFilter>) {
        self._selected = selected
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(SheikhFilter.allCases) { filter in
                    chip(for: filter)
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    @ViewBuilder
    private func chip(for filter: SheikhFilter) -> some View {
        let isSelected = selected == filter

        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selected = filter
            }
        } label: {
            Text(filter.rawValue)
                .dsFont(DSTypography.chipLabel)
                .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? dsColors.primary : dsColors.surfaceContainerLow)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: selected)
    }
}
