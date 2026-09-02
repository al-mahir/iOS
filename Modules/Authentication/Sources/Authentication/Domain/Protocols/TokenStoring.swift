//
//  TokenStoring.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

protocol TokenStoring {
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearTokens()
}
