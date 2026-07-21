//
//  ResetPasswordView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Common
import SwiftUI

public struct ForgetPasswordView: View {

    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    public init() {}

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {

                HeaderSection(
                    title: "Forget Password",
                    description:
                        "Enter your email and we'll send\nyou a reset link."
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

                AppButton(title: viewModel.isLoading ? "" : "Send Reset Link") {
                    viewModel.sendResetLink()
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

                hintNote
                    .padding(.top, DSSpacing.md)
                    .padding(.horizontal, DSSpacing.md)

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
            if viewModel.isEmailSent {
                successOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isEmailSent)
    }

    // MARK: - Form Section

    private var formSection: some View {
        DSTextField(
            label: "Email",
            placeholder: "example@email.com",
            text: $viewModel.email,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            autocapitalization: .never,
            autocorrectionDisabled: true
        )
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Hint Note

    private var hintNote: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(dsColors.textTertiary)
                .padding(.top, 1)

            Text(
                "Check your spam folder if you don't see the email within 2 minutes."
            )
            .dsFont(DSTypography.bodySmall)
            .foregroundColor(dsColors.textTertiary)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            dsColors.background
                .ignoresSafeArea()
                .opacity(0.96)

            VStack(spacing: DSSpacing.md) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(dsColors.successContainer)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(dsColors.success)
                }

                Text("Email Sent!")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text(
                    "We've sent a reset link to\n**\(viewModel.email)**\nPlease check your inbox."
                )
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
