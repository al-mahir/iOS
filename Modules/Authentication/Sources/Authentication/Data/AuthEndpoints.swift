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
        gender: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String
    )
    case refresh(refreshToken: String)
    case logout(idToken: String)
    case me(accessToken: String)
    case verifyOTP(otp: String, email: String)
    case verifyEmail(email: String)
    case changePassword(
        email: String,
        password: String,
        confirmPassword: String
    )
    case googleSignIn(idToken: String)

    var baseURL: BaseURLType { .almahir }

    var path: String {
        switch self {
        case .login:
            return "auth/user/login"

        case .register:
            return "auth/user/register"

        case .refresh:
            return "auth/user/refresh"

        case .logout:
            return "auth/logout"

        case .me:
            return "auth/me"

        case .verifyOTP(let otp, let email):
            return "forgot-password/verify-otp/\(otp)/\(email)"

        case .verifyEmail(let email):
            return "forgot-password/verify-email/\(email)"

        case .changePassword(let email, _, _):
            return "forgot-password/change-password/\(email)"

        case .googleSignIn:
            return "auth/user/google"
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
            let gender,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber
        ):
            return [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "gender": gender,
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

        case .logout(let idToken):
            return ["idToken": idToken]

        case .verifyOTP,
            .verifyEmail,
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

    var requiresAuthentication: Bool {
        switch self {
        case .logout, .me:
            return true
        default:
            return false
        }
    }

    var multipartBody: MultipartBody? {
        switch self {
        case .register(
            let username,
            let firstName,
            let lastName,
            let gender,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber
        ):
            let payload: [String: String] = [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "gender": gender,
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
