//
//  PremiumButtonView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common

struct PremiumButtonView: View {
    var onBuyPremium: () -> Void = {}
    var onRestorePurchases: () -> Void = {}
    var onSignOut: () -> Void = {}

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            // Buy Al-Māhir Premium Button
            Button(action: onBuyPremium) {
                Text("Buy Al-Māhir Premium")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                            .fill(dsColors.primary)
                    )
            }
            .buttonStyle(PressableScaleButtonStyle())

            // Restore purchases link
            Button(action: onRestorePurchases) {
                Text("Restore purchases")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
            }

            // Sign out Outlined Button
            Button(action: onSignOut) {
                HStack(spacing: DSSpacing.sm) {
                    Text("Sign out")
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.primary)

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(dsColors.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.full, style: .continuous)
                        .stroke(dsColors.primary, lineWidth: 1.5)
                )
            }
            .buttonStyle(PressableScaleButtonStyle())
        }
    }
}

private struct PressableScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    PremiumButtonView()
        .padding()
        .dsTheme()
}
