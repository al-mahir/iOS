//
//  ForgotPasswordViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 19/07/2026.
//
import Foundation
import Combine

@MainActor
public final class ForgotPasswordViewModel: ObservableObject {

    // MARK: - Form state
    @Published public var email = ""

    // MARK: - UI state
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var isEmailSent = false

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    public func sendResetLink() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        authManager.forgotPassword(email: email) { [weak self] in
            self?.isEmailSent = true
        }
    }

    public func clearError() {
        errorMessage = nil
    }
}
