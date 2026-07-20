//
//  GoogleSignInViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 19/07/2026.
//
import Foundation
import Combine
import GoogleSignIn

@MainActor
public final class GoogleSignInViewModel: ObservableObject {

    // MARK: - UI state
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    public init(authManager: AuthManager = .shared) {
        self.authManager = authManager

        authManager.$isLoading
            .assign(to: &$isLoading)

        authManager.$errorMessage
            .assign(to: &$errorMessage)
    }

    public func signIn(presentingViewController: UIViewController) {
        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            guard let self else { return }

            if let error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                return
            }

            guard
                let idToken = result?.user.idToken?.tokenString
            else {
                self.isLoading = false
                self.errorMessage = "Google Sign-In failed: could not retrieve ID token."
                return
            }

            self.authManager.googleSignIn(idToken: idToken)
        }
    }

    public func clearError() {
        errorMessage = nil
    }
}
