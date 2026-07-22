//
//  GoogleSignInViewModel.swift
//  Authentication
//
//  Created by Nadin Ahmed on 19/07/2026.
//

import Foundation
import Combine
import GoogleSignIn


struct GoogleSignInResult: @unchecked Sendable {
    let idToken: String?
    let error: Error?
    
    init(result: GIDSignInResult?, error: Error?) {
        self.idToken = result?.user.idToken?.tokenString
        self.error = error
    }
}

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
            // Create a Sendable wrapper
            let sendableResult = GoogleSignInResult(result: result, error: error)
            
            Task { @MainActor in
                guard let self else { return }

                if let error = sendableResult.error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let idToken = sendableResult.idToken else {
                    self.isLoading = false
                    self.errorMessage = "Google Sign-In failed: could not retrieve ID token."
                    return
                }

                self.authManager.googleSignIn(idToken: idToken)
            }
        }
    }

    public func clearError() {
        errorMessage = nil
    }
}
