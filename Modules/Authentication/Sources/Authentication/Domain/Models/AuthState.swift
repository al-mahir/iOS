//
//  AuthState.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

public enum AuthState: Sendable {
    case bootstrapping
    case guest
    case authenticated(AuthUser)
    case sessionExpired
}
