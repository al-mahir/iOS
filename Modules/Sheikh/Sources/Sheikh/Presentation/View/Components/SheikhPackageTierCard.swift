//
//  SheikhPackageTierCard.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhPackageTierCard: View {
    let package: SheikhPackage
    let onSelect: () -> Void

    @Environment(\.dsColors) private var dsColors

    public init(package: SheikhPackage, onSelect: @escaping () -> Void) {
        self.package = package
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header Row + Recommended Badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(package.titleFormatted)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                        .fontWeight(.bold)
                }

                Spacer()

                if package.isRecommended {
                    Text("RECOMMENDED")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.onPrimary)
                        .fontWeight(.bold)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(dsColors.primary)
                        )
                }
            }

            // Price Row
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.xxs) {
                Text("$\(package.pricePerMonth)")
                    .dsFont(DSTypography.headlineMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .fontWeight(.bold)

                Text("/month")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)

                Spacer()
            }

            // Frequency and Per Session details
            Text("\(package.daysPerWeek) · \(package.pricePerSession)")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)

            Divider()
                .foregroundColor(dsColors.outlineVariant)

            // Features List
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                ForEach(package.features, id: \.self) { feature in
                    HStack(spacing: DSSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(dsColors.primary)

                        Text(feature)
                            .dsFont(DSTypography.bodyMedium)
                            .foregroundColor(dsColors.textPrimary)
                    }
                }
            }

            // Action Button
            Button(action: onSelect) {
                Text("Select Package / اختيار الباقة")
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(package.isRecommended ? dsColors.onPrimary : dsColors.primary)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.smMd)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(package.isRecommended ? dsColors.primary : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.lg)
                                    .stroke(dsColors.primary, lineWidth: package.isRecommended ? 0 : 1.5)
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, DSSpacing.xs)
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.xl)
                .fill(package.isRecommended ? dsColors.primaryContainer.opacity(0.3) : dsColors.surfaceContainerLow)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .stroke(package.isRecommended ? dsColors.primary : dsColors.outlineVariant.opacity(0.5), lineWidth: package.isRecommended ? 2 : 1)
                )
        )
    }
}
