//
//  OTPView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Common
import SwiftUI

public struct OTPView: View {

    @ObservedObject public var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors
    @FocusState private var isFieldFocused: Bool

    public init(viewModel: ForgotPasswordViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.none) {

                HeaderSection(
                    title: "Check Your Email",
                    description:
                        "We sent a 6-digit code to \(viewModel.maskedEmail)"
                )
                .padding(.top, DSSpacing.xl)

                otpInputBoxesSection
                    .padding(.top, DSSpacing.xl)

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.clearError()
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                AppButton(title: viewModel.isLoading ? "" : "Verify Code") {
                    viewModel.verifyOTP()
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .disabled(viewModel.otpCode.count < 6 || viewModel.isLoading)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)

                resendTimerRow
                    .padding(.top, DSSpacing.lg)
                    .padding(.horizontal, DSSpacing.md)

                FooterWithButton(
                    message: "Wrong email?",
                    buttonText: "Change address",
                    onButtonClicked: {
                        dismiss()
                    }
                )
                .padding(.top, DSSpacing.xl2)
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
        .onAppear {
            isFieldFocused = true
        }
        .navigationDestination(isPresented: $viewModel.isOTPVerified) {
            ResetPasswordView(viewModel: viewModel)
        }
    }

    // MARK: - OTP Input Boxes Section

    private var otpInputBoxesSection: some View {
        ZStack {
            // Hidden textfield for standard keyboard handling
            TextField("", text: $viewModel.otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFieldFocused)
                .opacity(0.01)
                .onChange(of: viewModel.otpCode) { newValue in
                    if newValue.count > 6 {
                        viewModel.otpCode = String(newValue.prefix(6))
                    }
                }

            // Visible 6 Digit Boxes
            HStack(spacing: DSSpacing.xs) {
                ForEach(0..<6, id: \.self) { index in
                    digitBox(for: index)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFieldFocused = true
        }
    }

    private func digitBox(for index: Int) -> some View {
        let digit: String = {
            let code = viewModel.otpCode
            guard index < code.count else { return "" }
            let stringIndex = code.index(code.startIndex, offsetBy: index)
            return String(code[stringIndex])
        }()

        let isCurrentFocus =
            isFieldFocused
            && (index == viewModel.otpCode.count
                || (index == 5 && viewModel.otpCode.count == 6))

        return ZStack {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)

            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(
                    isCurrentFocus
                        ? dsColors.primary
                        : (!digit.isEmpty
                            ? dsColors.outline : dsColors.outlineVariant),
                    lineWidth: isCurrentFocus ? 2 : 1
                )

            Text(digit)
                .dsFont(DSTypography.headlineMedium)
                .foregroundColor(dsColors.textPrimary)
        }
        .frame(width: 48, height: 56)
    }

    // MARK: - Resend Timer Row

    private var resendTimerRow: some View {
        HStack(spacing: DSSpacing.xs) {
            Text("Didn't receive the code?")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)

            Spacer()

            if viewModel.isResendEnabled {
                Button {
                    viewModel.resendOTP()
                } label: {
                    Text("Resend code")
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.primary)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                HStack(spacing: DSSpacing.xxs) {
                    Text("Resend in")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)

                    Text(String(format: "00:%02d", viewModel.timeRemaining))
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.primary)
                }
            }
        }
    }
}
