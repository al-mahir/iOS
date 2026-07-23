//
//  SheikhStatItem.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhStatItem: View {

    public let value: String
    public let label: String
    @Environment(\.dsColors) private var dsColors

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }

    public var body: some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(value)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.primary)

            Text(label)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
