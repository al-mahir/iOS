//
//  CardSuccessView.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import SwiftUI
import Common

// MARK: - CardSuccessView

/// Full-screen success celebration shown after a card payment completes.
public struct CardSuccessView: View {

    public let result: CardPaymentResult
    public let onDone: () -> Void

    @Environment(\.dsColors) private var dsColors
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var contentOpacity: Double = 0
    @State private var ringsScale: CGFloat = 0.6
    @State private var ringsOpacity: Double = 0

    public init(result: CardPaymentResult, onDone: @escaping () -> Void) {
        self.result = result
        self.onDone = onDone
    }

    public var body: some View {
        ZStack {
            // MARK: Background gradient
            DSGradients.primary
                .ignoresSafeArea()

            // MARK: Ripple rings
            ZStack {
                ForEach(0..<3, id: \.self) { idx in
                    Circle()
                        .stroke(Color.white.opacity(0.12 - Double(idx) * 0.035), lineWidth: 1)
                        .frame(width: CGFloat(180 + idx * 60), height: CGFloat(180 + idx * 60))
                        .scaleEffect(ringsScale)
                        .opacity(ringsOpacity)
                }
            }

            // MARK: Content
            VStack(spacing: DSSpacing.xl) {

                Spacer()

                // Animated checkmark
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 96, height: 96)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)

                // Title
                VStack(spacing: DSSpacing.sm) {
                    Text("Payment Successful!")
                        .dsFont(DSTypography.headlineMedium)
                        .foregroundColor(.white)

                    Text("Your subscription has been activated.")
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .offset(y: contentOffset)
                .opacity(contentOpacity)

                // MARK: Transaction details card
                VStack(spacing: DSSpacing.none) {
                    ReceiptRow(
                        label: "Package",
                        value: result.packageTitle,
                        icon: "doc.text.fill"
                    )
                    Divider().background(Color.white.opacity(0.2))

                    ReceiptRow(
                        label: "Amount",
                        value: result.formattedAmount,
                        icon: "egyptianpound.circle.fill"
                    )
                    Divider().background(Color.white.opacity(0.2))

                    ReceiptRow(
                        label: "Card Brand",
                        value: result.cardProvider.displayName,
                        icon: "creditcard.fill"
                    )
                    Divider().background(Color.white.opacity(0.2))

                    ReceiptRow(
                        label: "Card",
                        value: "**** " + result.last4,
                        icon: "creditcard"
                    )
                    Divider().background(Color.white.opacity(0.2))

                    ReceiptRow(
                        label: "Transaction",
                        value: result.transactionID,
                        icon: "number.circle.fill"
                    )
                    Divider().background(Color.white.opacity(0.2))

                    ReceiptRow(
                        label: "Date",
                        value: result.formattedDate,
                        icon: "calendar"
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .fill(Color.white.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal, DSSpacing.md)
                .offset(y: contentOffset)
                .opacity(contentOpacity)

                Spacer()

                // Done button
                Button(action: onDone) {
                    Text("Done")
                        .dsFont(DSTypography.buttonText)
                        .foregroundColor(Color(hex: "#014F39"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.smMd)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
                .offset(y: contentOffset)
                .opacity(contentOpacity)
            }
        }
        .navigationBarHidden(true)
        .onAppear { runEntryAnimations() }
    }

    // MARK: Animations

    private func runEntryAnimations() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.65).delay(0.1)) {
            checkmarkScale  = 1
            checkmarkOpacity = 1
            ringsScale = 1.2
            ringsOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            contentOffset   = 0
            contentOpacity  = 1
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            ringsOpacity = 0
        }
    }
}

// MARK: - ReceiptRow

private struct ReceiptRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: DSSpacing.smMd) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.75))
                .frame(width: 20)

            Text(label)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(Color.white.opacity(0.75))

            Spacer()

            Text(value)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
    }
}
