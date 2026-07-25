import SwiftUI
import Common

struct TajweedLegendSheet: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator Handle
            Capsule()
                .fill(dsColors.outlineVariant)
                .frame(width: 40, height: 4)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.md)

            VStack(spacing: 4) {
                Text("Tajweed Color Guide")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .bold()

                Text("Tajweed Tarteel Color System")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(.bottom, DSSpacing.md)

            Divider()
                .background(dsColors.outlineVariant.opacity(0.5))
                .padding(.horizontal, DSSpacing.lg)

            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.md) {
                    ForEach(TajweedRule.allCases) { rule in
                        legendRow(for: rule)
                    }
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(dsColors.surfaceContainer.ignoresSafeArea())
    }

    private func legendRow(for rule: TajweedRule) -> some View {
        HStack(spacing: DSSpacing.md) {
            RoundedRectangle(cornerRadius: 6)
                .fill(rule.color)
                .frame(width: 24, height: 32)
            VStack(alignment: .leading, spacing: 2) {
                
                Text(rule.title)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .bold()
                    .multilineTextAlignment(.trailing)

                Text(rule.subtitle)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
