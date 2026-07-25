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

    public let onDismiss: () -> Void
    public let onCircleCreated: (CircleModel) -> Void

    @MainActor
    public init(
        viewModel: CreateCircleViewModel? = nil,
        onDismiss: @escaping () -> Void = {},
        onCircleCreated: @escaping (CircleModel) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? CreateCircleViewModel()
        )
        self.onDismiss = onDismiss
        self.onCircleCreated = onCircleCreated
    }

    public var body: some View {
        VStack(spacing: 0) {
            navigationBarHeader

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    circleNameField

                    topicPickerField

                    visibilitySegmentedField

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

            startCircleButton
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.lg)
        }
        .background(dsColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isVisible = false
        }
        .onDisappear {
            tabBarVisibility.isVisible = true
        }
    }

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

            Button("Save") {
                viewModel.createCircle { circle in
                    onCircleCreated(circle)
                    onDismiss()
                }
            }
            .dsFont(DSTypography.titleMedium)
            .foregroundColor(
                viewModel.isFormValid ? dsColors.primary : dsColors.textDisabled
            )
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
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

    private var topicPickerField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Topic / Surah")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            Menu {
                ForEach(viewModel.topics, id: \.self) { topic in
                    Button(topic) {
                        viewModel.selectedTopic = topic
                    }
                }
            } label: {
                HStack {
                    Text(
                        viewModel.selectedTopic.isEmpty
                            ? "Select Surah or Juz to read"
                            : viewModel.selectedTopic
                    )
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(
                        viewModel.selectedTopic.isEmpty
                            ? dsColors.textHint : dsColors.textPrimary
                    )

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(dsColors.textHint)
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.md)
                .background(dsColors.surfaceContainerLow)
                .cornerRadius(DSRadius.lg)
            }
        }
    }

    private var visibilitySegmentedField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Visibility")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            HStack(spacing: 0) {
                ForEach(CircleVisibility.allCases, id: \.self) { vis in
                    let isSelected = viewModel.visibility == vis
                    Button(action: {
                        viewModel.visibility = vis
                    }) {
                        Text(vis.title)
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

            Text(viewModel.visibility.helperText)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
        }
    }

    private var participantLimitField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Participant Limit")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            HStack {
                Button(action: { viewModel.decrementParticipantLimit() }) {
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
                    Text("\(viewModel.participantLimit)")
                        .dsFont(DSTypography.headlineMedium)
                        .foregroundColor(dsColors.textPrimary)

                    Text("participants")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                }

                Spacer()

                Button(action: { viewModel.incrementParticipantLimit() }) {
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

    private var startCircleButton: some View {
        Button(action: {
            viewModel.createCircle { circle in
                onCircleCreated(circle)
                onDismiss()
            }
        }) {
            Text("Start Circle Now")
                .dsFont(DSTypography.buttonText)
                .foregroundColor(dsColors.onPrimary)
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
