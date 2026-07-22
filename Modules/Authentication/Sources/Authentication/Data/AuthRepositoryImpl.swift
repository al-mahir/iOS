//
//  AuthRepositoryImpl.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Combine
import NetworkKit

final class AuthRepositoryImpl: AuthRepositoryProtocol {

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func login(email: String, password: String) -> AnyPublisher<LoginResponse, NetworkError> {
        networkService.request(AuthEndpoints.login(email: email, password: password))
    }

    func register(
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String
    ) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            AuthEndpoints.register(
                username: username,
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                confirmPassword: confirmPassword,
                phoneNumber: phoneNumber
            )
        )
    }

    func refresh(refreshToken: String) -> AnyPublisher<AuthTokens, NetworkError> {
        networkService.request(AuthEndpoints.refresh(refreshToken: refreshToken))
    }

    func logout(accessToken: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(AuthEndpoints.logout(accessToken: accessToken))
    }

    func getMe(accessToken: String) -> AnyPublisher<AuthUser, NetworkError> {
        networkService.request(AuthEndpoints.me(accessToken: accessToken))
    }

    func verifyEmail(email: String) -> AnyPublisher<MessageResponse, NetworkError> {
        networkService.request(AuthEndpoints.verifyEmail(email: email))
    }

    func changePassword(
        email: String,
        newPassword: String,
        confirmPassword: String
    ) -> AnyPublisher<MessageResponse, NetworkError> {
        networkService.request(
            AuthEndpoints.changePassword(
                email: email,
                password: newPassword,
                confirmPassword: confirmPassword
            )
        )
    }

    func googleSignIn(idToken: String) -> AnyPublisher<LoginResponse, NetworkError> {
        networkService.request(AuthEndpoints.googleSignIn(idToken: idToken))
    }
}
