//
//  OnboardingTooltipCard.swift
//  Common
//
//  Created by Basmala Abuzied Ahmed on 03/08/2026.
//

import SwiftUI

public struct OnboardingTooltipCard: View {
    let stepNumber: Int
    var totalSteps: Int = 6
    let description: String
    let buttonTitle: String
    let onNext: () -> Void

    @Environment(\.dsColors) private var dsColors
    
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
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Step \(stepNumber) of \(totalSteps)")
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.primary)

            Text(description)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onNext) {
                HStack(spacing: DSSpacing.xs) {
                    Text(buttonTitle)
                    if stepNumber < totalSteps {
                        Image(systemName: "arrow.right")
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
