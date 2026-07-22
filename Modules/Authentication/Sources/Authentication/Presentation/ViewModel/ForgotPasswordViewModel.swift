//
//  ForgotPasswordViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Foundation
import Combine

@MainActor
public final class ForgotPasswordViewModel: ObservableObject {

    // MARK: - Step 1: Email Form State
    @Published public var email = ""
    @Published public var isEmailSent = false

    // MARK: - Step 2: OTP Form State
    @Published public var otpCode = ""
    @Published public var timeRemaining = 30
    @Published public var isResendEnabled = false
    @Published public var isOTPVerified = false

    // MARK: - Step 3: Reset Password Form State
    @Published public var newPassword = ""
    @Published public var confirmPassword = ""
    @Published public var isResetSuccessful = false

    // MARK: - UI State
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies & Private Properties
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    // MARK: - Init
    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    // MARK: - Masked Email Helper
    public var maskedEmail: String {
        guard let atIndex = email.firstIndex(of: "@") else { return email }
        let namePart = email[..<atIndex]
        let domainPart = email[atIndex...]
        if namePart.count <= 2 {
            return String(namePart) + "***" + String(domainPart)
        } else {
            let prefix = namePart.prefix(1)
            return String(prefix) + "***" + String(domainPart)
        }
    }

    // MARK: - Actions

    public func sendResetLink() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        clearError()
        authManager.verifyEmail(email: trimmedEmail) { [weak self] in
            guard let self else { return }
            self.isEmailSent = true
            self.startResendTimer()
        }
    }

    public func verifyOTP() {
        guard otpCode.count == 6 else {
            errorMessage = "Please enter the complete 6-digit OTP code."
            return
        }
        clearError()
        authManager.verifyOTP(otp: otpCode, email: email) { [weak self] in
            guard let self else { return }
            self.stopResendTimer()
            self.isOTPVerified = true
        }
    }

    public func resendOTP() {
        guard isResendEnabled else { return }
        clearError()
        startResendTimer()
        authManager.verifyEmail(email: email) { }
    }

    public func resetPassword() {
        guard validateNewPassword() else { return }
        clearError()
        authManager.changePassword(
            email: email,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        ) { [weak self] in
            self?.isResetSuccessful = true
        }
    }

    public func clearError() {
        errorMessage = nil
    }

    // MARK: - Resend Timer Helpers

    public func startResendTimer() {
        stopResendTimer()
        timeRemaining = 30
        isResendEnabled = false

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.isResendEnabled = true
                    self.stopResendTimer()
                }
            }
    }

    public func stopResendTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    // MARK: - Private Validation

    private func validateNewPassword() -> Bool {
        if newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all password fields."
            return false
        }
        if newPassword.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        if newPassword != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        return true
    }
}
