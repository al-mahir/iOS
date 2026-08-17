//
//  CircleSearchField.swift
//  Circles
//

import Common
import SwiftUI

public struct CircleSearchField: View {
    @Binding private var query: String
    @Environment(\.dsColors) private var dsColors

    public init(query: Binding<String>) {
        _query = query
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
                .font(.system(size: 18, weight: .medium))

            TextField(localizedCircleString("Search circles..."), text: $query)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)

            if !query.isEmpty {
                Button(action: { query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(dsColors.textHint)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.lg)
    }
}
