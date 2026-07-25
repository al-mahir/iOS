//
//  JoinCircleView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct JoinCircleView: View {
    @StateObject private var viewModel: JoinCircleViewModel
    @Environment(\.dsColors) private var dsColors

    @State private var isPulsing = false

    @Environment(\.tabBarVisibility) private var tabBarVisibility

    public let onDismiss: () -> Void

    @MainActor
    public init(
        circle: CircleModel,
        viewModel: JoinCircleViewModel? = nil,
        onDismiss: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? JoinCircleViewModel(circle: circle)
        )
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            ActiveCirclesHeaderView(
                title: "Join Circle",
                onLeadingTap: onDismiss
            )

            Spacer()

            VStack(spacing: DSSpacing.xl) {
                clockGraphicIcon

                VStack(spacing: DSSpacing.xs) {
                    Text("Waiting for Approval...")
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(
                        "The host is verifying your request to join \(viewModel.circle.name) circle."
                    )
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
                }

                circleSummaryCard
            }

            Spacer()

            cancelButton
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
        }
        .background(dsColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isVisible = false
            withAnimation(
                .easeInOut(duration: 1.6)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .onDisappear {
            tabBarVisibility.isVisible = true
        }
    }

    private var clockGraphicIcon: some View {
        ZStack {
            // Outer glowing ring that expands and fades out
            Circle()
                .fill(dsColors.primary.opacity(0.2))
                .frame(width: 100, height: 100)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
                .opacity(isPulsing ? 0.05 : 0.5)

            // Inner soft pulsing aura
            Circle()
                .fill(dsColors.primaryContainer)
                .frame(width: 100, height: 100)
                .scaleEffect(isPulsing ? 1.15 : 0.95)
                .opacity(isPulsing ? 0.8 : 0.4)

            // Core clock circle
            Circle()
                .stroke(dsColors.primary.opacity(0.4), lineWidth: 2)
                .frame(width: 100, height: 100)

            Image(systemName: "clock")
                .font(.system(size: 42, weight: .regular))
                .foregroundColor(dsColors.primary)
        }
    }

    private var circleSummaryCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(viewModel.circle.name)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)

            HStack(spacing: DSSpacing.xs) {
                Text(
                    "\(viewModel.circle.sheikhName) · \(viewModel.circle.capacityText)"
                )
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)
            }

            if viewModel.circle.isLive {
                Text("LIVE")
                    .dsFont(DSTypography.badgeText)
                    .foregroundColor(Color.red)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(DSRadius.full)
            }
                    }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
    }

    private var cancelButton: some View {
        Button(action: {
            viewModel.cancelRequest {
                onDismiss()
            }
        }) {
            Text("Cancel Request")
                .dsFont(DSTypography.buttonText)
                .foregroundColor(dsColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
                .background(dsColors.surface)
                .cornerRadius(DSRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(dsColors.primary, lineWidth: 1.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.isLoading)
    }
}
