import Common
//
//  RegisterView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import SwiftUI

public struct RegisterView: View {

    @StateObject private var viewModel = RegisterViewModel()
    @StateObject private var googleViewModel = GoogleSignInViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showSuccessBanner = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {

                HeaderSection(
                    title: "Create Account",
                    description: "Join Al-Mahir — it takes under a minute."
                )

                formSection
                    .padding(.top, DSSpacing.lg)

                if let error = viewModel.errorMessage ?? googleViewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.clearError()
                        googleViewModel.clearError()
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                AppButton(title: "Sign Up") {
                    viewModel.register()
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)

                OrDivider()
                    .padding(.vertical, DSSpacing.md)

                DSGoogleButton(title: "Sign up with Google") {
                    if let vc = UIApplication.shared.topViewController() {
                        googleViewModel.signIn(presentingViewController: vc)
                    }
                }
                .disabled(googleViewModel.isLoading)
                .overlay {
                    if googleViewModel.isLoading {
                        ProgressView()
                    }
                }
                .padding(.horizontal, DSSpacing.md)

                FooterWithButton(
                    message: "Already have an account?",
                    buttonText: "Log in"
                ) {
                    dismiss()
                }
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(dsColors.textPrimary)
                }
            }
        }
        .dsTheme()
    }

    // MARK: - Form
    private var formSection: some View {
        VStack(spacing: DSSpacing.md) {

            // First Name + Last Name (side by side)
            HStack(spacing: DSSpacing.sm) {
                DSTextField(
                    label: "First Name",
                    placeholder: "Fatima",
                    text: $viewModel.firstName,
                    autocapitalization: .words
                )

                DSTextField(
                    label: "Last Name",
                    placeholder: "Al-Rashid",
                    text: $viewModel.lastName,
                    autocapitalization: .words
                )
            }

            // Username
            DSTextField(
                label: "Username",
                placeholder: "@username",
                text: $viewModel.username,
                leadingIcon: "at",
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            // Email
            DSTextField(
                label: "Email",
                placeholder: "example@email.com",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            // Password
            DSTextField(
                label: "Password",
                placeholder: "••••••••",
                text: $viewModel.password,
                isSecure: true,
                textContentType: .newPassword
            )

            // Confirm Password
            DSTextField(
                label: "Confirm Password",
                placeholder: "••••••••",
                text: $viewModel.confirmPassword,
                isSecure: true,
                errorMessage: passwordMismatchError,
                textContentType: .newPassword
            )
        }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Helpers

    private var passwordMismatchError: String? {
        guard !viewModel.password.isEmpty,
            !viewModel.confirmPassword.isEmpty,
            viewModel.password != viewModel.confirmPassword
        else { return nil }
        return "Passwords do not match"
    }
}
