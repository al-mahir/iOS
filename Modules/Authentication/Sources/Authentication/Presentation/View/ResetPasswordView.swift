//
//  ResetPasswordView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Common
import SwiftUI

public struct ResetPasswordView: View {

    @ObservedObject public var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    public init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {

                HeaderSection(
                    title: "Create New Password",
                    description: "Your new password must be different from previously used passwords."
                )

                formSection
                    .padding(.top, DSSpacing.lg)

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.clearError()
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                AppButton(title: viewModel.isLoading ? "" : "Reset Password") {
                    viewModel.resetPassword()
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)

                FooterWithButton(
                    message: "Remember your password?",
                    buttonText: "Log in",
                    onButtonClicked: {
                        dismiss()
                    }
                )
                .padding(.top, DSSpacing.xl)
                .padding(.bottom, DSSpacing.xl2)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .dsFont(DSTypography.labelLarge)
                    }
                    .foregroundColor(dsColors.primary)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
        .dsTheme()
        .overlay {
            if viewModel.isResetSuccessful {
                successOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isResetSuccessful)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: DSSpacing.md) {
            DSTextField(
                label: "New Password",
                placeholder: "••••••••",
                text: $viewModel.newPassword,
                isSecure: true,
                textContentType: .newPassword
            )

            DSTextField(
                label: "Confirm New Password",
                placeholder: "••••••••",
                text: $viewModel.confirmPassword,
                isSecure: true,
                textContentType: .newPassword
            )
        }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            dsColors.background
                .ignoresSafeArea()
                .opacity(0.96)

            VStack(spacing: DSSpacing.md) {
                ZStack {
                    Circle()
                        .fill(dsColors.successContainer)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(dsColors.success)
                }

                Text("Password Reset!")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text("Your password has been successfully reset.\nYou can now log in with your new password.")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)

                AppButton(title: "Back to Log In") {
                    dismiss()
                }
                .padding(.horizontal, DSSpacing.xl)
                .padding(.top, DSSpacing.sm)
            }
            .padding(DSSpacing.xl)
        }
    }
}
