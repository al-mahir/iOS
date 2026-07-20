//
//  InteractionState.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//


import SwiftUI

public enum DSInteractionOpacity {
    public static let hover: Double = 0.08
    public static let pressed: Double = 0.12
    public static let focused: Double = 0.12
    public static let dragged: Double = 0.16
    public static let selected: Double = 0.16
    public static let disabledContent: Double = 0.38
    public static let disabledBackground: Double = 0.12
    public static let ripple: Double = 0.10
}


public struct DSPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dsColors) private var dsColors

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsFont(DSTypography.buttonText)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(isEnabled ? dsColors.primary : dsColors.primary.opacity(DSInteractionOpacity.disabledBackground))
            )
            .foregroundColor(dsColors.onPrimary)
            .opacity(configuration.isPressed ? (1 - DSInteractionOpacity.pressed) : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
