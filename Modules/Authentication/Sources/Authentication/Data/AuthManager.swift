//
//  AuthManager.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import NetworkKit
import Combine

@MainActor
public final class AuthManager: ObservableObject {

    public static let shared = AuthManager()

    // MARK: - Published state

    @Published public private(set) var authState: AuthState = .bootstrapping
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let repository: AuthRepositoryProtocol
    private let tokenStore: TokenStoring
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Refresh

    private var isRefreshing = false
    private var pendingRefreshCallbacks: [@Sendable (Bool) -> Void] = []

    // MARK: - User Defaults Key
    
    private static let hasLaunchedBeforeKey = "AuthManager.hasLaunchedBefore"
    // MARK: - Init

    private init(
        repository: AuthRepositoryProtocol = AuthRepositoryImpl(),
        tokenStore: TokenStoring = KeychainTokenStore()
    ) {
        self.repository = repository
        self.tokenStore = tokenStore
    }

    // MARK: - Nonisolated token access

    nonisolated public var currentAccessToken: String? {
        KeychainTokenStore().getAccessToken()
    }

    nonisolated public static func configureInterceptor() {
        AppRequestInterceptors.shared.tokenProvider = {
            KeychainTokenStore().getAccessToken()
        }

        AppRequestInterceptors.shared.onRefreshNeeded =
            { completion in
                Task { @MainActor in
                    AuthManager.shared.refreshTokensForInterceptor(
                        completion: completion
                    )
                }
            } as (@escaping @Sendable (Bool) -> Void) -> Void
    }

    // MARK: - AuthStateProviding conformance

    public var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }

    public var currentAuthState: AuthState { authState }

    // MARK: - Silent login on app launch

    public func silentLoginOnLaunch() {
        clearKeychainIfFreshInstall()
        
        guard let accessToken = tokenStore.getAccessToken() else {
            authState = .guest
            return
        }
        isLoading = true
        repository.getMe(accessToken: accessToken)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    self.tryRefreshOnLaunch()
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.isLoading = false
                self.authState = .authenticated(user)
            }
            .store(in: &cancellables)
    }

    private func tryRefreshOnLaunch() {
        guard let refreshToken = tokenStore.getRefreshToken() else {
            isLoading = false
            authState = .guest
            return
        }
        repository.refresh(refreshToken: refreshToken)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure = completion {
                    self.tokenStore.clearTokens()
                    self.authState = .guest
                }
            } receiveValue: { [weak self] tokens in
                guard let self else { return }
                try? self.tokenStore.saveTokens(
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken
                )
                self.fetchCurrentUser(accessToken: tokens.accessToken)
            }
            .store(in: &cancellables)
    }

    private func fetchCurrentUser(accessToken: String) {
        repository.getMe(accessToken: accessToken)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure = completion { self.authState = .guest }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.isLoading = false
                self.authState = .authenticated(user)
            }
            .store(in: &cancellables)
    }

    // MARK: - Login

    public func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        repository.login(email: email, password: password)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                try? self.tokenStore.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                self.authState = .authenticated(response.user)
            }
            .store(in: &cancellables)
    }

    // MARK: - Register

    public func register(
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String,
        onSuccess: @escaping () -> Void
    ) {
        isLoading = true
        errorMessage = nil
        repository.register(
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: phoneNumber
        )
        .sink { [weak self] completion in
            guard let self else { return }
            self.isLoading = false
            if case .failure(let error) = completion {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] (_: Bool) in
            self?.isLoading = false
            onSuccess()
        }
        .store(in: &cancellables)
    }

    // MARK: - Logout

    public func logout() {
        guard let accessToken = tokenStore.getAccessToken() else {
            clearSession()
            return
        }
        isLoading = true
        repository.logout(accessToken: accessToken)
            .sink { [weak self] _ in
                self?.isLoading = false
                self?.clearSession()
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }

    // MARK: - Password Reset Flow (Verify Email, Verify OTP, Change Password)

    public func verifyEmail(email: String, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        repository.verifyEmail(email: email)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.isLoading = false
                onSuccess()
            }
            .store(in: &cancellables)
    }

    public func verifyOTP(otp: String, email: String, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        repository.verifyOTP(otp: otp, email: email)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.isLoading = false
                onSuccess()
            }
            .store(in: &cancellables)
    }

    public func changePassword(
        email: String,
        newPassword: String,
        confirmPassword: String,
        onSuccess: @escaping () -> Void
    ) {
        isLoading = true
        errorMessage = nil
        repository.changePassword(
            email: email,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
        .sink { [weak self] completion in
            guard let self else { return }
            self.isLoading = false
            if case .failure(let error) = completion {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] _ in
            self?.isLoading = false
            onSuccess()
        }
        .store(in: &cancellables)
    }

    // MARK: - Google Sign-In

    public func googleSignIn(idToken: String) {
        isLoading = true
        errorMessage = nil
        repository.googleSignIn(idToken: idToken)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                try? self.tokenStore.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                self.authState = .authenticated(response.user)
            }
            .store(in: &cancellables)
    }

    // MARK: - Token refresh for AppRequestInterceptors

    public func refreshTokensForInterceptor(
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        if isRefreshing {
            pendingRefreshCallbacks.append(completion)
            return
        }
        guard let refreshToken = tokenStore.getRefreshToken() else {
            authState = .sessionExpired
            completion(false)
            return
        }

        isRefreshing = true
        pendingRefreshCallbacks.append(completion)

        repository.refresh(refreshToken: refreshToken)
            .sink { [weak self] result in
                guard let self else { return }
                self.isRefreshing = false
                if case .failure = result {
                    self.tokenStore.clearTokens()
                    self.authState = .sessionExpired
                    self.pendingRefreshCallbacks.forEach { $0(false) }
                    self.pendingRefreshCallbacks.removeAll()
                }
            } receiveValue: { [weak self] tokens in
                guard let self else { return }
                self.isRefreshing = false
                try? self.tokenStore.saveTokens(
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken
                )
                self.pendingRefreshCallbacks.forEach { $0(true) }
                self.pendingRefreshCallbacks.removeAll()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - clear tokens in first lunch
    
    private func clearKeychainIfFreshInstall() {
        let defaults = UserDefaults.standard
        let hasLaunchedBefore = defaults.bool(forKey: Self.hasLaunchedBeforeKey)

        if !hasLaunchedBefore {
            tokenStore.clearTokens()
            defaults.set(true, forKey: Self.hasLaunchedBeforeKey)
        }
    }

    // MARK: - Private helpers

    private func clearSession() {
        tokenStore.clearTokens()
        authState = .guest
    }
}


extension AuthManager: AuthStateProviding {}

extension AuthManager: AuthUseCaseProtocol {}
