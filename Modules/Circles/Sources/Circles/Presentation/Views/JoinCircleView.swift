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

    public let restoreTabBarOnDisappear: Bool
    public let onDismiss: () -> Void

    // MARK: - Init: Public circle (no pre-existing membership)

    @MainActor
    public init(
        circle: CircleModel,
        viewModel: JoinCircleViewModel? = nil,
        restoreTabBarOnDisappear: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? JoinCircleViewModel(
                circle: circle,
                joinCircleUseCase: JoinCircleUseCase(repository: CircleRepository()),
                leaveCircleUseCase: LeaveCircleUseCase(repository: CircleRepository()),
                repository: CircleRepository()
            )
        )
        self.restoreTabBarOnDisappear = restoreTabBarOnDisappear
        self.onDismiss = onDismiss
    }

    // MARK: - Init: Private circle (membership already obtained from banner)

    @MainActor
    public init(
        circle: CircleModel,
        pendingMembership: CircleMembership,
        restoreTabBarOnDisappear: Bool = false,
        onDismiss: @escaping () -> Void = {}
    ) {
        let vm = JoinCircleViewModel(
            circle: circle,
            joinCircleUseCase: JoinCircleUseCase(repository: CircleRepository()),
            leaveCircleUseCase: LeaveCircleUseCase(repository: CircleRepository()),
            repository: CircleRepository()
        )
        vm.startPendingWithMembership(pendingMembership)
        _viewModel = StateObject(wrappedValue: vm)
        self.restoreTabBarOnDisappear = restoreTabBarOnDisappear
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            ActiveCirclesHeaderView(
                title: viewModel.circle.name,
                onLeadingTap: onDismiss
            )

            Spacer()

            Group {
                switch viewModel.joinState {
                case .pending:
                    pendingContent

                case .approved:
                    approvedContent

                case .rejected(let reason):
                    rejectedContent(reason: reason)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.joinState)

            Spacer()

            if viewModel.joinState == .pending {
                cancelButton
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, DSSpacing.xl)
            }
        }
        .background(dsColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isVisible = false
            startPulseAnimation()
            // For public circles the membership hasn't been obtained yet — trigger join now.
            if viewModel.membership == nil {
                viewModel.joinPublic()
            }
        }
        .onDisappear {
            if restoreTabBarOnDisappear {
                tabBarVisibility.isVisible = true
            }
        }
        // Auto-dismiss when approved after a short delay
        .onChange(of: viewModel.joinState) { newState in
            if case .approved = newState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onDismiss()
                }
            }
        }
    }

    // MARK: - Pending State (waiting for owner approval)

    private var pendingContent: some View {
        VStack(spacing: DSSpacing.xl) {
            clockGraphicIcon

            VStack(spacing: DSSpacing.xs) {
                Text("Waiting for Approval...")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(
                    "The host is verifying your request to join \"\(viewModel.circle.name)\"."
                )
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.lg)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
            }

            circleSummaryCard
        }
    }

    // MARK: - Approved State

    private var approvedContent: some View {
        VStack(spacing: DSSpacing.xl) {
            ZStack {
                Circle()
                    .fill(dsColors.success.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(dsColors.success)
            }

            VStack(spacing: DSSpacing.xs) {
                Text("You're In!")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text("Welcome to \"\(viewModel.circle.name)\".")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
            }
        }
        .transition(.opacity.combined(with: .scale))
    }

    // MARK: - Rejected State

    private func rejectedContent(reason: String) -> some View {
        VStack(spacing: DSSpacing.xl) {
            ZStack {
                Circle()
                    .fill(dsColors.error.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(dsColors.error)
            }

            VStack(spacing: DSSpacing.xs) {
                Text("Request Declined")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text(reason.isEmpty ? "Your join request was not approved." : reason)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.lg)
            }

            Button(action: onDismiss) {
                Text("Go Back")
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
            .padding(.horizontal, DSSpacing.md)
        }
        .transition(.opacity.combined(with: .scale))
    }

    // MARK: - Shared Sub-views

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
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(dsColors.textHint)

                Text(formattedDate(viewModel.circle.startDate))
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)

                Text("·")
                    .foregroundColor(dsColors.textHint)

                Text("\(viewModel.circle.memberCount)/\(viewModel.circle.maxParticipants) participants")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, DSSpacing.md)
    }

    private var cancelButton: some View {
        Button(action: {
            viewModel.leaveOrCancel {
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

    // MARK: - Helpers

    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.6)
            .repeatForever(autoreverses: true)
        ) {
            isPulsing = true
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
