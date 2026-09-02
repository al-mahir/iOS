//
//  DSGoogleButton.swift
//  Common
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import SwiftUI

public struct DSGoogleButton: View {

    public let title: String
    public let action: () -> Void

    @Environment(\.dsColors) private var dsColors
    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed = false

    public init(title: String = "Sign in with Google", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Image("google-icon", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(title)
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(dsColors.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .stroke(dsColors.outlineVariant, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : DSInteractionOpacity.disabledContent)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.15)) { isPressed = false }
                }
        )
        .animation(.easeOut(duration: 0.15), value: isPressed)
        .disabled(!isEnabled)
    }
}
