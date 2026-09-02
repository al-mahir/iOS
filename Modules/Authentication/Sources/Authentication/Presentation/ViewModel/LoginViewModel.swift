import Combine
//
//  LoginViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

@MainActor
public final class LoginViewModel: ObservableObject {

    // MARK: - Form state

    @Published public var email = ""
    @Published public var password = ""

    // MARK: - UI state (mirrored from AuthManager)

    @Published public var isLoading = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    // MARK: - Actions

    public func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        authManager.login(email: email, password: password)
    }

    public func clearError() {
        errorMessage = nil
    }
}
