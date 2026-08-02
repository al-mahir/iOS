//
//  WaitingForApprovalView.swift
//  Sheikh
//

import SwiftUI
import Common

// MARK: - Waiting for Approval Overlay

struct WaitingForApprovalView: View {

    let sheikhName: String
    let sheikhAvatarURL: String?
    let onCancel: () -> Void

    // MARK: Animation State

    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring3Scale: CGFloat = 1.0
    @State private var ring1Opacity: Double = 0.5
    @State private var ring2Opacity: Double = 0.35
    @State private var ring3Opacity: Double = 0.20
    @State private var dotPhase: Int = 0

    @Environment(\.dsColors) private var dsColors

    // MARK: Body

    var body: some View {
        ZStack {
            // Scrim background
            dsColors.background
                .opacity(0.96)
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.xl) {
                Spacer()

                // Pulsing rings + avatar
                pulsingAvatarStack

                // Status text
                statusText

                Spacer()

                // Cancel button
                cancelButton
                    .padding(.horizontal, DSSpacing.xl)
                    .padding(.bottom, DSSpacing.xl2)
            }
        }
        .onAppear { startAnimations() }
        .onDisappear { stopAnimations() }
    }

    // MARK: - Subviews

    private var pulsingAvatarStack: some View {
        ZStack {
            // Ring 3 — outermost
            Circle()
                .stroke(dsColors.primary.opacity(ring3Opacity), lineWidth: 1.5)
                .frame(width: 180, height: 180)
                .scaleEffect(ring3Scale)

            // Ring 2 — middle
            Circle()
                .stroke(dsColors.primary.opacity(ring2Opacity), lineWidth: 2)
                .frame(width: 144, height: 144)
                .scaleEffect(ring2Scale)

            // Ring 1 — inner
            Circle()
                .stroke(dsColors.primary.opacity(ring1Opacity), lineWidth: 3)
                .frame(width: 112, height: 112)
                .scaleEffect(ring1Scale)

            // Avatar circle
            avatarCircle
        }
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(dsColors.primaryContainer)
                .frame(width: 88, height: 88)

            if let urlStr = sheikhAvatarURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipShape(Circle())
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(dsColors.primary)
    }

    private var statusText: some View {
        VStack(spacing: DSSpacing.smMd) {
            Text("Waiting for Sheikh's Approval")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)
                .multilineTextAlignment(.center)

            // Animated ellipsis dots
            HStack(spacing: DSSpacing.xs) {
                Text(sheikhName)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)

                HStack(spacing: DSSpacing.xxs) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(dsColors.textSecondary)
                            .frame(width: 4, height: 4)
                            .opacity(dotPhase == index ? 1.0 : 0.3)
                    }
                }
            }

            Text("Your request has been sent. Please wait.")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.xl)
        }
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Cancel Request")
                    .dsFont(DSTypography.buttonText)
            }
            .foregroundColor(dsColors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.smMd)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(dsColors.error, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .fill(dsColors.errorContainer.opacity(0.15))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Animations

    private func startAnimations() {
        // Inner ring — fastest
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            ring1Scale = 1.08
            ring1Opacity = 0.8
        }

        // Middle ring — medium delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                ring2Scale = 1.1
                ring2Opacity = 0.55
            }
        }

        // Outer ring — slowest
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(
                .easeInOut(duration: 1.4)
                .repeatForever(autoreverses: true)
            ) {
                ring3Scale = 1.12
                ring3Opacity = 0.35
            }
        }

        // Animated dots timer
        animateDots()
    }

    private func stopAnimations() {
        ring1Scale = 1.0
        ring2Scale = 1.0
        ring3Scale = 1.0
    }

    private func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.2)) {
                dotPhase = (dotPhase + 1) % 3
            }
        }
    }
}
