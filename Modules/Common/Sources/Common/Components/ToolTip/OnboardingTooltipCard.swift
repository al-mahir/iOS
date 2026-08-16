//
//  OnboardingTooltipCard.swift
//  Common
//
//  Created by Basmala Abuzied Ahmed on 03/08/2026.
//

import SwiftUI

public struct OnboardingTooltipCard: View {

    let stepNumber: Int
    let totalSteps: Int
    let description: String
    let buttonTitle: String
    let onNext: () -> Void

    @Environment(\.dsColors)
    private var dsColors

    @Environment(\.layoutDirection)
    private var layoutDirection

    public init(
        stepNumber: Int,
        description: String,
        buttonTitle: String,
        onNext: @escaping () -> Void,
        totalSteps: Int = 6
    ) {
        self.stepNumber = stepNumber
        self.description = description
        self.buttonTitle = buttonTitle
        self.onNext = onNext
        self.totalSteps = totalSteps
    }

    private var stepText: String {
        let format = LanguageManager.localizedString(
            "onboarding.tooltip.step",
            bundle: .module
        )
        return String(format: format, stepNumber, totalSteps)
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: DSSpacing.sm
        ) {

            Text(stepText)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.primary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Text(description)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Button(action: onNext) {
                HStack(spacing: DSSpacing.xs) {

                    Text(buttonTitle)

                    if stepNumber < totalSteps {
                        Image(
                            systemName:
                                layoutDirection == .rightToLeft
                                ? "arrow.left"
                                : "arrow.right"
                        )
                    }
                }
                .dsFont(DSTypography.buttonText)
                .foregroundColor(dsColors.primary)
            }
            .padding(.top, DSSpacing.xs)
        }
        .padding(DSSpacing.md)
        .frame(width: 260)
        .background(dsColors.surfaceContainer)
        .cornerRadius(DSRadius.md)
        .dsElevation(DSElevation.level3)
    }
}
