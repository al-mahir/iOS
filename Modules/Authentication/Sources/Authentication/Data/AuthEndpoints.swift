//
//  AuthEndpoints.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import NetworkKit
import Alamofire

enum AuthEndpoints: APIEndpoint {

    case login(email: String, password: String)
    case register(
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String
    )
    case refresh(refreshToken: String)
    case logout(accessToken: String)
    case me(accessToken: String)
    case forgotPassword(email: String)
    case resetPassword(
        token: String,
        newPassword: String,
        confirmPassword: String
    )
    case googleSignIn(idToken: String)

    var baseURL: BaseURLType { .main }

    var path: String {
        switch self {
        case .login: return "auth/login"
        case .register: return "auth/register"
        case .refresh: return "auth/refresh"
        case .logout: return "auth/logout"
        case .me: return "auth/me"
        case .forgotPassword: return "auth/forgot-password"
        case .resetPassword: return "auth/reset-password"
        case .googleSignIn: return "auth/google"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me: return .get
        default: return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]

        case .register(
            let username,
            let firstName,
            let lastName,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber
        ):
            return [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "confirmPassword": confirmPassword,
                "phoneNumber": phoneNumber,
            ]

        case .refresh(let refreshToken):
            return ["refreshToken": refreshToken]

        case .forgotPassword(let email):
            return ["email": email]

        case .resetPassword(let token, let newPassword, let confirmPassword):
            return [
                "token": token,
                "newPassword": newPassword,
                "confirmPassword": confirmPassword,
            ]

        case .googleSignIn(let idToken):
            return ["idToken": idToken]

        case .logout, .me:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .me: return URLEncoding.default
        default: return JSONEncoding.default
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        // Endpoints that require a Bearer token
        case .me(let accessToken), .logout(let accessToken):
            return [
                "Authorization": "Bearer \(accessToken)",
                "Accept": "application/json",
            ]

        // Public endpoints — no auth header needed
        default:
            return [
                "Accept": "application/json",
                "Content-Type": "application/json",
            ]
        }
    }
}
