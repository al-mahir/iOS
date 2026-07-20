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
        HStack(spacing: 4) {
            ForEach(SearchCategory.allCases) { category in
                Text(category.rawValue)
                    .dsFont(DSTypography.labelLarge)
                    .foregroundColor(viewModel.selectedCategory == category ? dsColors.onPrimary : dsColors.textSecondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.selectedCategory == category ? dsColors.primary : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.updateCategory(category)
                        }
                    }
            }
        }
        .padding(4)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}
