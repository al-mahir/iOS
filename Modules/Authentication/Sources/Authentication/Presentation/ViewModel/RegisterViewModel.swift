//
//  RegisterViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Combine

@MainActor
public final class RegisterViewModel: ObservableObject {

    // MARK: - Form state

    @Published public var username = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var phoneNumber = ""

    // MARK: - UI state

    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var registrationSuccessful = false

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

    public func register() {
        guard validate() else { return }
        authManager.register(
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: phoneNumber
        ) { [weak self] in
            self?.registrationSuccessful = true
        }
    }

    public func clearError() {
        errorMessage = nil
    }

    // MARK: - Private

    private func validate() -> Bool {
        if username.isEmpty || firstName.isEmpty || lastName.isEmpty
            || email.isEmpty || password.isEmpty || confirmPassword.isEmpty
            || phoneNumber.isEmpty
        {
            errorMessage = "Please fill in all fields."
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        return true
    }
}
