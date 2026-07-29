//
//  SheikhDemographicsGrid.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhDemographicsGrid: View {
    let sheikh: Sheikh
    @Environment(\.dsColors) private var dsColors

    public init(sheikh: Sheikh) {
        self.sheikh = sheikh
    }

    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DSSpacing.smMd),
                GridItem(.flexible(), spacing: DSSpacing.smMd)
            ],
            spacing: DSSpacing.smMd
        ) {
            gridCard(
                iconName: "person.2",
                label: "Target",
                value: sheikh.targetAudience
            )

            gridCard(
                iconName: "globe",
                label: "Languages",
                value: sheikh.formattedLanguages
            )

            gridCard(
                iconName: "book",
                label: "Qira'at",
                value: sheikh.formattedQiraat
            )

            gridCard(
                iconName: "star",
                label: "Experience",
                value: "\(sheikh.experienceYears) Years"
            )
        }
    }

    private func gridCard(iconName: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(dsColors.primary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(dsColors.primaryContainer.opacity(0.4))
                )

            Text(label)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textSecondary)

            Text(value)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
                .fontWeight(.bold)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(DSSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
