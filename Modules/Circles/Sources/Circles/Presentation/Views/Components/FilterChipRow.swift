//
//  FilterChipRow.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct FilterChipRow: View {
    @Environment(\.dsColors) private var dsColors
    public let categories: [String]
    @Binding public var selectedCategory: String

    public init(categories: [String], selectedCategory: Binding<String>) {
        self.categories = categories
        self._selectedCategory = selectedCategory
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = category == selectedCategory
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(
                                isSelected
                                    ? dsColors.onPrimary : dsColors.textPrimary
                            )
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isSelected
                                    ? dsColors.primary
                                    : dsColors.surfaceContainerLow
                            )
                            .cornerRadius(DSRadius.full)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}
