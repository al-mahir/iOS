//
//  CircleCodeEntryCard.swift
//  Circles
//  Created by Nadin Ahmed on 04/08/2026.
//

import Common
import SwiftUI

public struct PrivateCodeBanner: View {
    @StateObject var viewModel: ActiveCirclesViewModel
    @Environment(\.dsColors) private var dsColors

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Header row
            HStack(spacing: DSSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 32, height: 32)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Join a Private Circle")
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                    Text("Enter the code shared by the host")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                }

                Spacer()
            }

            // Session ID + Password inputs
            VStack(spacing: DSSpacing.sm) {
                TextField("Session ID", text: $viewModel.privateSessionId)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.smMd)
                    .background(dsColors.surfaceContainerLow)
                    .cornerRadius(DSRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(
                                viewModel.privateCodeError != nil
                                    ? dsColors.error
                                    : dsColors.outlineVariant,
                                lineWidth: 1
                            )
                    )

                HStack(spacing: DSSpacing.sm) {
                    TextField("Password", text: $viewModel.privatePassword)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textPrimary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.smMd)
                        .background(dsColors.surfaceContainerLow)
                        .cornerRadius(DSRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(
                                    viewModel.privateCodeError != nil
                                        ? dsColors.error
                                        : dsColors.outlineVariant,
                                    lineWidth: 1
                                )
                        )
                        .frame(maxWidth: .infinity)

                    Button(action: { viewModel.joinWithCode() }) {
                        Group {
                            if viewModel.isJoiningWithCode {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(
                                            tint: dsColors.onPrimary
                                        )
                                    )
                                    .scaleEffect(0.85)
                                    .frame(width: 52)
                            } else {
                                Text("Join")
                                    .dsFont(DSTypography.buttonText)
                                    .foregroundColor(dsColors.onPrimary)
                                    .frame(width: 52)
                            }
                        }
                        .padding(.vertical, DSSpacing.smMd)
                        .background(
                            isJoinDisabled
                                ? dsColors.primary.opacity(0.5)
                                : dsColors.primary
                        )
                        .cornerRadius(DSRadius.md)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isJoinDisabled)
                }
            }

            // Inline error
            if let error = viewModel.privateCodeError {
                Text(error)
                    .dsFont(DSTypography.inputError)
                    .foregroundColor(dsColors.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.privateCodeError)
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.4), lineWidth: 1)
        )
        .dsElevation(DSElevation.level1)
    }

    // MARK: - Helpers

    private var isJoinDisabled: Bool {
        viewModel.isJoiningWithCode
            || viewModel.privateSessionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.privatePassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
