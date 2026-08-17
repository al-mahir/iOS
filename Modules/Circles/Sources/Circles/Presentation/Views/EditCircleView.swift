//
//  EditCircleView.swift
//  Circles
//
//  Created by Nadin Ahmed on 15/08/2026.
//

import Common
import SwiftUI

public struct EditCircleView: View {
    @StateObject private var viewModel: EditCircleViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    private let onDismiss: () -> Void
    private let onCircleUpdated: (CircleModel) -> Void

    @MainActor
    public init(
        circle: CircleModel,
        viewModel: EditCircleViewModel? = nil,
        onDismiss: @escaping () -> Void = {},
        onCircleUpdated: @escaping (CircleModel) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel ?? EditCircleViewModel(
            circle: circle,
            updateCircleUseCase: UpdateCircleUseCase(repository: CircleRepository())
        ))
        self.onDismiss = onDismiss
        self.onCircleUpdated = onCircleUpdated
    }

    public var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    CircleScheduleFields(
                        name: $viewModel.name,
                        startDate: $viewModel.startDate,
                        endDate: $viewModel.endDate
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.error)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.md)
            }

            saveButton
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
        }
        .background(dsColors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear { tabBarVisibility.isVisible = false }
    }

    private var header: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(dsColors.primary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Edit Circle")
                .dsFont(DSTypography.titleLarge)
                .foregroundColor(dsColors.textPrimary)

            Spacer()

            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(dsColors.surface)
        .overlay(Divider().foregroundColor(dsColors.outlineVariant), alignment: .bottom)
    }

    private var saveButton: some View {
        Button {
            viewModel.save { updatedCircle in
                onCircleUpdated(updatedCircle)
                onDismiss()
            }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: dsColors.onPrimary))
                } else {
                    Text("Save Changes")
                        .dsFont(DSTypography.buttonText)
                }
            }
            .foregroundColor(dsColors.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(viewModel.isFormValid ? dsColors.primary : dsColors.textDisabled)
            .cornerRadius(DSRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!viewModel.isFormValid || viewModel.isSaving)
    }
}
