//
//  AuthTokens.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

struct AuthTokens: Decodable {
    let accessToken: String
    let refreshToken: String
}
