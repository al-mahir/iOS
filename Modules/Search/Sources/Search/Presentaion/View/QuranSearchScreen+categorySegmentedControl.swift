//
//  QuranSearchScreen+categorySegmentedControl.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
extension QuranSearchScreen {
    var categorySegmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(SearchCategory.allCases) { category in
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.selectedCategory == category ? AppColors.background : .gray)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.selectedCategory == category ? AppColors.primaryAccent : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.updateCategory(category)
                        }
                    }
            }
        }
        .padding(4)
        .background(AppColors.surface)
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}
