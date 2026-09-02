//
//  PrivateCodeBanner.swift
//  Circles
//

import Common
import SwiftUI

public struct PrivateCodeBanner: View {
    @ObservedObject var viewModel: PrivateCirclesViewModel
    @Environment(\.dsColors) private var dsColors

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 32, height: 32)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("Join a Private Circle", bundle: .module)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                    Text("Enter the token shared by the host", bundle: .module)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                }

                Spacer()
            }

            DSTextField(
                placeholder: localizedCircleString("Invite token"),
                text: $viewModel.privateToken,
                errorMessage: viewModel.privateTokenError,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            Button(action: viewModel.joinWithToken) {
                Group {
                    if viewModel.isJoiningWithToken {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: dsColors.onPrimary)
                            )
                    } else {
                        Text("Join Circle", bundle: .module)
                            .dsFont(DSTypography.buttonText)
                    }
                }
                .foregroundColor(dsColors.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.smMd)
                .background(isJoinDisabled ? dsColors.primary.opacity(0.5) : dsColors.primary)
                .cornerRadius(DSRadius.md)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isJoinDisabled)
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.4), lineWidth: 1)
        )
        .dsElevation(DSElevation.level1)
    }

    private var isJoinDisabled: Bool {
        viewModel.isJoiningWithToken
            || viewModel.privateToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
