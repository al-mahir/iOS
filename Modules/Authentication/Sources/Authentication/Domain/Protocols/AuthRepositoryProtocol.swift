//
//  AuthRepositoryProtocol.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Combine
import NetworkKit

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, NetworkError>
    
    func register(
        username: String,
        firstName: String,
        lastName: String,
        gender: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String
    ) -> AnyPublisher<Bool, NetworkError>
    
    func refresh(refreshToken: String) -> AnyPublisher<AuthTokens, NetworkError>
    
    func logout(idToken: String) -> AnyPublisher<Bool, NetworkError>
    
    func getMe(accessToken: String) -> AnyPublisher<AuthUser, NetworkError>

    func verifyEmail(email: String) -> AnyPublisher<MessageResponse, NetworkError>

    func verifyOTP(otp: String, email: String) -> AnyPublisher<MessageResponse, NetworkError>

    func changePassword(
        email: String,
        newPassword: String,
        confirmPassword: String
    ) -> AnyPublisher<MessageResponse, NetworkError>

    func googleSignIn(idToken: String) -> AnyPublisher<LoginResponse, NetworkError>
}
