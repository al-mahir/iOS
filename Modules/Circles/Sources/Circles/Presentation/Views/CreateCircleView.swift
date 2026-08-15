//
//  CreateCircleView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct CreateCircleView: View {
    @StateObject private var viewModel: CreateCircleViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    // MARK: - Invite overlay state
    @State private var showInviteOverlay: Bool = false
    @State private var createdCircle: CircleModel? = nil

    public let restoreTabBarOnDisappear: Bool
    public let onDismiss: () -> Void
    public let onCircleCreated: (CircleModel) -> Void

    @MainActor
    public init(
        viewModel: CreateCircleViewModel? = nil,
        restoreTabBarOnDisappear: Bool = false,
        onDismiss: @escaping () -> Void = {},
        onCircleCreated: @escaping (CircleModel) -> Void = { _ in }
    ) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(
                wrappedValue: CreateCircleViewModel(
                    createCircleUseCase: CreateCircleUseCase(
                        repository: CircleRepository()
                    )
                )
            )
        }
        self.restoreTabBarOnDisappear = restoreTabBarOnDisappear
        self.onDismiss = onDismiss
        self.onCircleCreated = onCircleCreated
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBarHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {
                        privateByDefaultNote

                        circleNameField

                        genderSegmentedField

                        startDateField

                        endDateField

                        participantLimitField

                        requireApprovalCard

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.error)
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.md)
                    .padding(.bottom, DSSpacing.xl)
                }

                Spacer()

                createCircleButton
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, DSSpacing.lg)
            }
            .background(dsColors.background)

            if showInviteOverlay, let circle = createdCircle {
                inviteOverlay(circle: circle)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeOut(duration: 0.25), value: showInviteOverlay)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isVisible = false
        }
        .onDisappear {
            if restoreTabBarOnDisappear {
                tabBarVisibility.isVisible = true
            }
        }
    }

    // MARK: - Navigation Bar

    private var navigationBarHeader: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(dsColors.primary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Create New Circle")
                .dsFont(DSTypography.titleLarge)
                .foregroundColor(dsColors.textPrimary)

            Spacer()

        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(dsColors.surface)
        .overlay(
            Divider().foregroundColor(dsColors.outlineVariant),
            alignment: .bottom
        )
    }

    // MARK: - Private-by-default note

    private var privateByDefaultNote: some View {
        HStack(alignment: .center, spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer)
                    .frame(width: 32, height: 32)
                Image(systemName: "lock.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dsColors.primary)
            }
            
            Text("Private Circle, only people with the invite token can join.")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.sm)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.md)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Circle Name

    private var circleNameField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Circle Name")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            TextField(
                "e.g., Daily Fajr Recitation",
                text: $viewModel.circleName
            )
            .dsFont(DSTypography.bodyMedium)
            .foregroundColor(dsColors.textPrimary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.md)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
    }

    // MARK: - Gender

    private var genderSegmentedField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Gender")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            HStack(spacing: 0) {
                ForEach(Gender.allCases, id: \.self) { option in
                    let isSelected = viewModel.gender == option
                    Button(action: {
                        viewModel.gender = option
                    }) {
                        Text(option.displayTitle)
                            .dsFont(DSTypography.titleSmall)
                            .foregroundColor(
                                isSelected
                                    ? dsColors.onPrimary
                                    : dsColors.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.smMd)
                            .background(
                                isSelected
                                    ? dsColors.primary
                                    : dsColors.surfaceContainerLow
                            )
                            .cornerRadius(DSRadius.md)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
    }

    // MARK: - Dates

    private var startDateField: some View {
        VStack(alignment: .center, spacing: DSSpacing.xs) {
            Text("Start Date & Time")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker(
                "",
                selection: $viewModel.startDate,
                in: Date().addingTimeInterval(-3600)...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(dsColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
        .frame(maxWidth: .infinity)
    }

    private var endDateField: some View {
        VStack(alignment: .center, spacing: DSSpacing.xs) {
            Text("End Date & Time")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            DatePicker(
                "",
                selection: $viewModel.endDate,
                in: viewModel.startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(dsColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Participant Limit

    private var participantLimitField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Participant Limit")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            HStack {
                Button(action: { viewModel.decrementParticipants() }) {
                    ZStack {
                        Circle()
                            .fill(dsColors.surface)
                            .frame(width: 44, height: 44)

                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                VStack(spacing: 2) {
                    Text("\(viewModel.maxParticipants)")
                        .dsFont(DSTypography.headlineMedium)
                        .foregroundColor(dsColors.textPrimary)

                    Text("participants")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                }

                Spacer()

                Button(action: { viewModel.incrementParticipants() }) {
                    ZStack {
                        Circle()
                            .fill(dsColors.primary)
                            .frame(width: 44, height: 44)

                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(dsColors.onPrimary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(DSSpacing.md)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
    }

    // MARK: - Require Approval

    private var requireApprovalCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text("Require Approval")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)

                Text("Manually approve each participant")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)
            }

            Spacer()

            Toggle("", isOn: $viewModel.requiresApproval)
                .labelsHidden()
                .tint(dsColors.primary)
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Invite Overlay

    private func inviteOverlay(circle: CircleModel) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 56, height: 56)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                }

                VStack(spacing: DSSpacing.xs) {
                    Text("Circle Created Successfully")
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(dsColors.textPrimary)

                    Text("Share this token with participants so they can join.")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: DSSpacing.xs) {
                    Text("Token")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.textHint)
                    Text(circle.inviteToken ?? "Token unavailable")
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DSSpacing.md)
                .background(dsColors.surfaceContainerLow)
                .cornerRadius(DSRadius.lg)

                // Copy Button
                Button(action: {
                    UIPasteboard.general.string = circle.inviteToken
                    showInviteOverlay = false
                    onCircleCreated(circle)
                    onDismiss()
                }) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Copy Token")
                            .dsFont(DSTypography.buttonText)
                    }
                    .foregroundColor(dsColors.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.md)
                    .background(dsColors.primary)
                    .cornerRadius(DSRadius.lg)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(DSSpacing.xl)
            .background(dsColors.surface)
            .cornerRadius(DSRadius.xl)
            .padding(.horizontal, DSSpacing.lg)
        }
    }

    // MARK: - Create Button

    private var createCircleButton: some View {
        Button(action: {
            viewModel.createCircle { circle in
                createdCircle = circle
                showInviteOverlay = true
            }
        }) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: dsColors.onPrimary))
                } else {
                    Text("Create Circle")
                        .dsFont(DSTypography.buttonText)
                        .foregroundColor(dsColors.onPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(
                viewModel.isFormValid
                    ? dsColors.primary : dsColors.textDisabled
            )
            .cornerRadius(DSRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
}
