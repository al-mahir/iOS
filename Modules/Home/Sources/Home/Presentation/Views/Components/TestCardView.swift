//
//  TestCardView.swift
//  Home
//
//  Created by Basmala Abuzied Ahmed on 04/08/2026.
//

import SwiftUI
import Common

public struct TestCardView: View {
    @Environment(\.dsColors) private var dsColors
    let onTap: () -> Void

    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.md) {
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 48, height: 48)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("Quran Recitation Test")
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    Text("Test your memorization & track progress")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(dsColors.surfaceContainerLow)
            )
            .dsElevation(DSElevation.level1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
