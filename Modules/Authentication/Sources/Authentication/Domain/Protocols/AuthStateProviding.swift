//
//  AuthStateProviding.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Combine

@MainActor
public protocol AuthStateProviding: AnyObject {
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    var currentAuthState: AuthState { get }
}
