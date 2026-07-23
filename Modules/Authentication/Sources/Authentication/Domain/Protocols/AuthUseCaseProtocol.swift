//
//  AuthUseCaseProtocol.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

@MainActor
public protocol AuthUseCaseProtocol: AnyObject {
    func login(email: String, password: String)

    func register(
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String,
        onSuccess: @escaping () -> Void
    )
    
    func logout()
    
    func silentLoginOnLaunch()

    func verifyEmail(email: String, onSuccess: @escaping () -> Void)

    func verifyOTP(otp: String, email: String, onSuccess: @escaping () -> Void)

    func changePassword(
        email: String,
        newPassword: String,
        confirmPassword: String,
        onSuccess: @escaping () -> Void
    )
    
    func googleSignIn(idToken: String)
}
