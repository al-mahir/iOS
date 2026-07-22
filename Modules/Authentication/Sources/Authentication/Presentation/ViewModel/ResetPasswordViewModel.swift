//
//  ResetPasswordViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 19/07/2026.
//
import Foundation
import Combine

@MainActor
public final class ResetPasswordViewModel: ObservableObject {

    // MARK: - Form state

    @Published public var token = ""
    @Published public var newPassword = ""
    @Published public var confirmPassword = ""

    // MARK: - UI state

    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var isResetSuccessful = false

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    public func resetPassword() {
        guard validate() else { return }
        authManager.resetPassword(
            token: token,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        ) { [weak self] in
            self?.isResetSuccessful = true
        }
    }

    public func clearError() {
        errorMessage = nil
    }

    // MARK: - Private

    private func validate() -> Bool {
        if token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all fields."
            return false
        }
        if newPassword != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        return true
    }
}
