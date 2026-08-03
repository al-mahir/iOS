//
//  CardProviderCard.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import SwiftUI
import Common

// MARK: - CardProviderCard

/// A tappable card representing a single card payment provider (e.g. Visa, Mastercard).
/// Animates a selection ring and applies the provider's brand accent color.
struct CardProviderCard: View {

    let provider: CardProvider
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.dsColors) private var dsColors
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DSSpacing.sm) {

                // MARK: Icon circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: provider.brandPrimaryHex),
                                    Color(hex: provider.brandSecondaryHex)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)

                    Image(systemName: provider.symbolName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(
                    color: Color(hex: provider.brandPrimaryHex).opacity(isSelected ? 0.5 : 0.2),
                    radius: isSelected ? 12 : 4,
                    x: 0, y: 4
                )

                // MARK: Provider name
                Text(provider.displayName)
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(isSelected ? Color(hex: provider.brandPrimaryHex) : dsColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, DSSpacing.md)
            .padding(.horizontal, DSSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(
                        isSelected
                        ? Color(hex: provider.brandPrimaryHex).opacity(0.08)
                        : dsColors.surfaceContainerLow
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .strokeBorder(
                        isSelected
                        ? Color(hex: provider.brandPrimaryHex)
                        : dsColors.outlineVariant,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = true } }
                .onEnded   { _ in withAnimation(.easeOut(duration: 0.15)) { isPressed = false } }
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
