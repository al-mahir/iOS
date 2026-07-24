//
//  TajweedLegendSheet.swift
//  Mushaf
//
//  Presented from MushafFloatingActionButton — replaces the tajweed legend
//  row that used to live permanently inside the fixed bottom card.
//

import SwiftUI
import Common

struct TajweedLegendSheet: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: DSSpacing.sm),
        GridItem(.flexible(), spacing: DSSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Capsule()
                .fill(dsColors.outlineVariant)
                .frame(width: 36, height: 4)
                .padding(.top, DSSpacing.sm)

            Text("Tajweed Colors")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            LazyVGrid(columns: columns, spacing: DSSpacing.sm) {
                ForEach(TajweedRule.allCases) { rule in
                    legendRow(for: rule)
                }
            }
            .padding(.horizontal, DSSpacing.md)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(dsColors.surfaceContainer.ignoresSafeArea())
    }

    private func legendRow(for rule: TajweedRule) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(rule.color)
                .frame(width: 10, height: 10)
            Text(rule.title)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
