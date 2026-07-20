import Common
//
//  LoginView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import SwiftUI

public struct LoginView: View {

    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var googleViewModel = GoogleSignInViewModel()
    @Environment(\.dsColors) private var dsColors
    @State private var showRegister = false
    @State private var showForgotPassword = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.none) {

                    HeaderSection(
                        title: "Welcome Back",
                        description: "Sign in to continue to your account."
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

                    AppButton(title: viewModel.isLoading ? "" : "Log In") {
                        viewModel.login()
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

                    OrDivider()
                        .padding(.vertical, DSSpacing.md)

                    DSGoogleButton(title: "Log in with Google") {

                    }
                    .disabled(googleViewModel.isLoading)
                    .overlay {
                        if googleViewModel.isLoading {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)

                    FooterWithButton(
                        message: "Don't have an account?",
                        buttonText: "Sign up",
                        onButtonClicked: {
                            showRegister = true
                        }
                    )
                    .padding(.top, DSSpacing.lg)
                    .padding(.bottom, DSSpacing.xl2)
                }
            }
            .background(dsColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .animation(
                .easeInOut(duration: 0.25),
                value: viewModel.errorMessage
            )
            .animation(
                .easeInOut(duration: 0.25),
                value: googleViewModel.errorMessage
            )
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .dsTheme()
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgetPasswordView()
            }
        }
        .dsTheme()
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: DSSpacing.md) {

            // Username
            DSTextField(
                label: "Email",
                placeholder: "example@email.com",
                text: $viewModel.email,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            // Password + Forgot Password
            VStack(alignment: .trailing, spacing: DSSpacing.xs) {
                DSTextField(
                    label: "Password",
                    placeholder: "••••••••",
                    text: $viewModel.password,
                    isSecure: true,
                    textContentType: .password
                )

                Button {
                    showForgotPassword = true
                } label: {
                    Text("Forgot Password?")
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, DSSpacing.md)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }
}
