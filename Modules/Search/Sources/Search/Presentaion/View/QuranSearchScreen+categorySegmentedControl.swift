//
//  QuranSearchScreen+categorySegmentedControl.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common
extension QuranSearchScreen {
    var categorySegmentedControl: some View {
        HStack(spacing: 6) {
            ForEach(SearchCategory.allCases) { category in
                categoryTab(category)
            }
        }
        .padding(5)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(14)
        .padding(.horizontal, DSSpacing.md)
    }

    @ViewBuilder
    private func categoryTab(_ category: SearchCategory) -> some View {
        let isSelected = viewModel.selectedCategory == category

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                viewModel.updateCategory(category)
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                Text(category.rawValue)
                    .dsFont(DSTypography.labelLarge)
            }
            .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? dsColors.primary : Color.clear)
                    .shadow(
                        color: isSelected ? dsColors.primary.opacity(0.35) : .clear,
                        radius: 6, x: 0, y: 3
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.0 : 0.97)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
