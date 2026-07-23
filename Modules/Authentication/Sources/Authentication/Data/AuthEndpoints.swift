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
    case verifyOTP(otp: String, email: String)
    case verifyEmail(email: String)
    case changePassword(
        email: String,
        password: String,
        confirmPassword: String
    )
    case googleSignIn(idToken: String)

    var baseURL: BaseURLType { .main }

    var path: String {
        switch self {
        case .login:
            return "api/auth/user/login"

        case .register:
            return "api/auth/user/register"

        case .refresh:
            return "api/auth/user/refresh"

        case .logout:
            return "api/auth/logout"

        case .me:
            return "auth/me"

        case .verifyOTP(let otp, let email):
            return "forgot-password/verify-otp/\(otp)/\(email)"

        case .verifyEmail(let email):
            return "forgot-password/verify-email/\(email)"

        case .changePassword(let email, _, _):
            return "forgot-password/change-password/\(email)"

        case .googleSignIn:
            return "api/auth/user/google"
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
            return [
                "email": email,
                "password": password,
            ]

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
            return [
                "refreshToken": refreshToken
            ]

        case .changePassword(_, let password, let confirmPassword):
            return [
                "password": password,
                "confirm_password": confirmPassword,
            ]

        case .verifyOTP,
            .verifyEmail,
            .logout,
            .me:
            return nil

        case .googleSignIn(let idToken):
            return [
                "idToken": idToken
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .me:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var multipartBody: MultipartBody? {
        switch self {
        case .register(
            let username,
            let firstName,
            let lastName,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber
        ):
            let payload: [String: String] = [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "confirmPassword": confirmPassword,
                "phoneNumber": phoneNumber,
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                return nil
            }
            return MultipartBody(parts: [
                MultipartPart(name: "data", data: jsonData, mimeType: "application/json")
            ])

        default:
            return nil
        }
    }
}
