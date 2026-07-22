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

// MARK: - ViewModel

@MainActor
public final class GoogleSignInViewModel: ObservableObject {

    // MARK: - Constants

    private static let iosClientID =
        "643197199024-pejrku9mnd0ibqhhup0lipi2c4323eko.apps.googleusercontent.com"
    private static let serverClientID =
        "384576791903-84qf1ktk46ath5dlpqg4ooig1t23n7us.apps.googleusercontent.com"

    // MARK: - Published State

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

        let config = GIDConfiguration(
            clientID: Self.iosClientID,
            serverClientID: Self.serverClientID
        )
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            let sendableResult = GoogleSignInResult(result: result, error: error)

            Task { @MainActor [weak self] in
                guard let self else { return }

                if let error = sendableResult.error {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let googleIdToken = sendableResult.idToken else {
                    self.isLoading = false
                    self.errorMessage = "Google Sign-In failed: could not retrieve Google ID token."
                    return
                }

                self.authManager.googleSignIn(idToken: googleIdToken)
            }
        }
    }

    public func clearError() {
        errorMessage = nil
    }
}
