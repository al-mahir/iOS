//
//  LoginResponse.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser
    /// Present only on Google Sign-In responses; nil for standard login.
    let isNewUser: Bool?
}
