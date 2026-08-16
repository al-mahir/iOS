//
//  PaymentAwaitingView.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import SwiftUI
import Common

private final class PaymentBundleToken {}

// MARK: - PaymentAwaitingView

/// Shown after Paymob sends an OTP to the user's wallet phone.
/// The user must open their wallet app and confirm the payment.
public struct PaymentAwaitingView: View {

    public let transactionID: String
    public let provider: WalletProvider
    public let maskedPhone: String
    public let onConfirmed: () -> Void
    public let onCancel: () -> Void

    @Environment(\.dsColors) private var dsColors
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    @State private var instructionOpacity: Double = 0
    @State private var dotAnimSteps: [Bool] = [false, false, false]

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    public init(
        transactionID: String,
        provider: WalletProvider,
        maskedPhone: String,
        onConfirmed: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.transactionID = transactionID
        self.provider      = provider
        self.maskedPhone   = maskedPhone
        self.onConfirmed   = onConfirmed
        self.onCancel      = onCancel
    }

    public var body: some View {
        ZStack {
            dsColors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.xl) {

                Spacer()

                // MARK: Pulsing wallet icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color(hex: provider.brandPrimaryHex).opacity(0.2), lineWidth: 1)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)

                    // Middle ring
                    Circle()
                        .stroke(Color(hex: provider.brandPrimaryHex).opacity(0.15), lineWidth: 1.5)
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale * 0.9)

                    // Icon container
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
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: provider.brandPrimaryHex).opacity(0.4), radius: 16, x: 0, y: 6)

                    Image(systemName: provider.symbolName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
                .onAppear { startPulseAnimation() }

                // MARK: Status text
                VStack(spacing: DSSpacing.sm) {
                    HStack(spacing: DSSpacing.xs) {
                        Text(
                            NSLocalizedString(
                                "awaiting_status_title",
                                bundle: Self.bundle,
                                value: "Waiting for confirmation",
                                comment: "Status header while awaiting wallet confirmation"
                            )
                        )
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.textPrimary)

                        // Animated dots
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { idx in
                                Circle()
                                    .fill(dsColors.primary)
                                    .frame(width: 5, height: 5)
                                    .opacity(dotAnimSteps[idx] ? 1 : 0.2)
                            }
                        }
                        .onAppear { startDotAnimation() }
                    }

                    Text(
                        String(
                            format: NSLocalizedString(
                                "awaiting_otp_sent_subtitle",
                                bundle: Self.bundle,
                                value: "An OTP has been sent to your %@ wallet",
                                comment: "Format string for OTP sent notification"
                            ),
                            provider.displayName
                        )
                    )
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                }
                .opacity(instructionOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                        instructionOpacity = 1
                    }
                }

                // MARK: Phone info card
                VStack(spacing: DSSpacing.sm) {
                    HStack(spacing: DSSpacing.smMd) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: provider.brandPrimaryHex))

                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text(
                                NSLocalizedString(
                                    "awaiting_wallet_number_label",
                                    bundle: Self.bundle,
                                    value: "Wallet Number",
                                    comment: "Label for wallet number info row"
                                )
                            )
                            .dsFont(DSTypography.labelSmall)
                            .foregroundColor(dsColors.textSecondary)

                            Text(maskedPhone)
                                .dsFont(DSTypography.titleSmall)
                                .foregroundColor(dsColors.textPrimary)
                        }
                        Spacer()
                    }

                    Divider()

                    HStack(spacing: DSSpacing.smMd) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(dsColors.textSecondary)

                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text(
                                NSLocalizedString(
                                    "receipt_label_transaction",
                                    bundle: Self.bundle,
                                    value: "Transaction ID",
                                    comment: "Label for transaction ID info row"
                                )
                            )
                            .dsFont(DSTypography.labelSmall)
                            .foregroundColor(dsColors.textSecondary)

                            Text(transactionID)
                                .dsFont(DSTypography.labelMedium)
                                .foregroundColor(dsColors.textPrimary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                    }
                }
                .padding(DSSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .fill(dsColors.surfaceContainerLow)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .strokeBorder(dsColors.outlineVariant, lineWidth: 1)
                )
                .padding(.horizontal, DSSpacing.md)

                // MARK: Instructions
                VStack(spacing: DSSpacing.sm) {
                    InstructionStep(
                        number: "1",
                        text: String(
                            format: NSLocalizedString(
                                "awaiting_instruction_step_1",
                                bundle: Self.bundle,
                                value: "Open your %@ app or check your SMS",
                                comment: "First step instruction to confirm wallet payment"
                            ),
                            provider.displayName
                        ),
                        brandColor: Color(hex: provider.brandPrimaryHex)
                    )
                    InstructionStep(
                        number: "2",
                        text: NSLocalizedString(
                            "awaiting_instruction_step_2",
                            bundle: Self.bundle,
                            value: "Approve the payment request of \u{200F}EGP",
                            comment: "Second step instruction to approve payment request"
                        ),
                        brandColor: Color(hex: provider.brandPrimaryHex)
                    )
                    InstructionStep(
                        number: "3",
                        text: NSLocalizedString(
                            "awaiting_instruction_step_3",
                            bundle: Self.bundle,
                            value: "Come back here and tap \"I've Confirmed\"",
                            comment: "Third step instruction to finalize in-app flow"
                        ),
                        brandColor: Color(hex: provider.brandPrimaryHex)
                    )
                }
                .padding(.horizontal, DSSpacing.md)

                Spacer()

                // MARK: Action buttons
                VStack(spacing: DSSpacing.sm) {
                    Button(action: onConfirmed) {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text(
                                String(
                                    format: NSLocalizedString(
                                        "awaiting_confirm_button",
                                        bundle: Self.bundle,
                                        value: "I've Confirmed in %@",
                                        comment: "Confirmation action button title"
                                    ),
                                    provider.displayName
                                )
                            )
                            .dsFont(DSTypography.buttonText)
                        }
                        .padding(.vertical, DSSpacing.smMd)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DSPrimaryButtonStyle())

                    Button(action: onCancel) {
                        Text(
                            NSLocalizedString(
                                "awaiting_cancel_button",
                                bundle: Self.bundle,
                                value: "Cancel Payment",
                                comment: "Button to cancel pending payment"
                            )
                        )
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.error)
                        .padding(.vertical, DSSpacing.sm)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
            }
        }
        .navigationBarHidden(true)
        .dsTheme()
    }

    // MARK: Animations

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.6)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale   = 1.18
            pulseOpacity = 0.15
        }
    }

    private func startDotAnimation() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.2)
            ) {
                dotAnimSteps[i] = true
            }
        }
    }
}

// MARK: - InstructionStep

private struct InstructionStep: View {
    let number: String
    let text: String
    let brandColor: Color
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.smMd) {
            ZStack {
                Circle()
                    .fill(brandColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text(number)
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(brandColor)
            }
            Text(text)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}
