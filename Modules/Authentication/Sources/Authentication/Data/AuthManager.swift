//
//  AuthManager.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import NetworkKit
import Combine
import Common
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
    
    private var cachedAuthUser: AuthUser? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "AuthManager.cachedAuthUser") else { return nil }
            return try? JSONDecoder().decode(AuthUser.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "AuthManager.cachedAuthUser")
                NotificationCenter.default.post(name: .userSessionDidChange, object: newValue.id)
            } else {
                UserDefaults.standard.removeObject(forKey: "AuthManager.cachedAuthUser")
                NotificationCenter.default.post(name: .userSessionDidChange, object: nil)
            }
        }
    }
    // MARK: - Init

    private init(
        repository: AuthRepositoryProtocol = AuthRepositoryImpl(),
        tokenStore: TokenStoring = KeychainTokenStore()
    ) {
        self.repository = repository
        self.tokenStore = tokenStore
        
        NotificationCenter.default.publisher(for: .appLogoutRequested)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.logout()
            }
            .store(in: &cancellables)
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
        
        if let cachedUser = cachedAuthUser {
            authState = .authenticated(cachedUser)
        } else {
            isLoading = true
        }
        
        repository.getMe(accessToken: accessToken)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError, case .unauthorized = networkError {
                        self.tryRefreshOnLaunch()
                    } else if self.cachedAuthUser == nil {
                        self.authState = .guest
                    }
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.isLoading = false
                let userWithDate = self.processUser(user)
                self.cachedAuthUser = userWithDate
                self.authState = .authenticated(userWithDate)
                SessionManager.shared.save(user: SessionUser(id: userWithDate.id, username: userWithDate.username, email: userWithDate.email, fullName: userWithDate.fullName, profilePictureUrl: userWithDate.profilePictureUrl, createdAt: userWithDate.createdAt))
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
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError, case .unauthorized = networkError {
                        self.clearSession()
                    } else if self.cachedAuthUser == nil {
                        self.authState = .guest
                    }
                }
            } receiveValue: { [weak self] tokens in
                guard let self else { return }
                do {
                    try self.tokenStore.saveTokens(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken
                    )
                    self.fetchCurrentUser(accessToken: tokens.accessToken)
                } catch {
                    print("🔴 [AuthManager] Keychain save failed during launch refresh: \(error)")
                    self.clearSession()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchCurrentUser(accessToken: String) {
        repository.getMe(accessToken: accessToken)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    if let networkError = error as? NetworkError, case .unauthorized = networkError {
                        self.clearSession()
                    } else if self.cachedAuthUser == nil {
                        self.authState = .guest
                    }
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.isLoading = false
                let userWithDate = self.processUser(user)
                self.cachedAuthUser = userWithDate
                self.authState = .authenticated(userWithDate)
                SessionManager.shared.save(user: SessionUser(id: userWithDate.id, username: userWithDate.username, email: userWithDate.email, fullName: userWithDate.fullName, profilePictureUrl: userWithDate.profilePictureUrl, createdAt: userWithDate.createdAt))
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
                do {
                    try self.tokenStore.saveTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    let userWithDate = self.processUser(response.user)
                    self.cachedAuthUser = userWithDate
                    self.authState = .authenticated(userWithDate)
                    SessionManager.shared.save(user: SessionUser(id: userWithDate.id, username: userWithDate.username, email: userWithDate.email, fullName: userWithDate.fullName, profilePictureUrl: userWithDate.profilePictureUrl, createdAt: userWithDate.createdAt))
                } catch {
                    print("🔴 [AuthManager] Keychain save failed during login: \(error)")
                    self.errorMessage = "Failed to save session. Please try again."
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Register

    public func register(
        username: String,
        firstName: String,
        lastName: String,
        gender: String,
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
            gender: gender,
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
        guard tokenStore.getAccessToken() != nil,
              let refreshToken = tokenStore.getRefreshToken()
        else {
            clearSession()
            return
        }
        isLoading = true
        repository.logout(idToken: refreshToken)
            .sink { [weak self] completion in
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
                do {
                    try self.tokenStore.saveTokens(
                        accessToken: response.accessToken,
                        refreshToken: response.refreshToken
                    )
                    let userWithDate = self.processUser(response.user)
                    self.cachedAuthUser = userWithDate
                    self.authState = .authenticated(userWithDate)
                    SessionManager.shared.save(user: SessionUser(id: userWithDate.id, username: userWithDate.username, email: userWithDate.email, fullName: userWithDate.fullName, profilePictureUrl: userWithDate.profilePictureUrl, createdAt: userWithDate.createdAt))
                } catch {
                    print("🔴 [AuthManager] Keychain save failed during Google Sign-In: \(error)")
                    self.errorMessage = "Failed to save session. Please try again."
                }
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
                if case .failure(let error) = result {
                    if let networkError = error as? NetworkError, case .unauthorized = networkError {
                        self.clearSession()
                        self.authState = .sessionExpired
                        self.pendingRefreshCallbacks.forEach { $0(false) }
                    } else {
                        self.pendingRefreshCallbacks.forEach { $0(false) }
                    }
                    self.pendingRefreshCallbacks.removeAll()
                }
            } receiveValue: { [weak self] tokens in
                guard let self else { return }
                self.isRefreshing = false
                do {
                    try self.tokenStore.saveTokens(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken
                    )
                    self.pendingRefreshCallbacks.forEach { $0(true) }
                } catch {
                    print("🔴 [AuthManager] Keychain save failed after token refresh: \(error)")
                    self.clearSession()
                    self.authState = .sessionExpired
                    self.pendingRefreshCallbacks.forEach { $0(false) }
                }
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
    
    private func getPersistedDate(for userId: String) -> Date {
        let key = "AuthManager.createdAt.\(userId)"
        if let timeInterval = UserDefaults.standard.object(forKey: key) as? TimeInterval {
            return Date(timeIntervalSince1970: timeInterval)
        } else {
            let newDate = Date()
            UserDefaults.standard.set(newDate.timeIntervalSince1970, forKey: key)
            return newDate
        }
    }
    
    private func processUser(_ user: AuthUser) -> AuthUser {
        var mutableUser = user
        mutableUser.createdAt = getPersistedDate(for: user.id)
        return mutableUser
    }

    private func clearSession() {
        tokenStore.clearTokens()
        cachedAuthUser = nil
        SessionManager.shared.clear()
        authState = .guest
    }
}


extension AuthManager: AuthStateProviding {}

extension AuthManager: AuthUseCaseProtocol {}
