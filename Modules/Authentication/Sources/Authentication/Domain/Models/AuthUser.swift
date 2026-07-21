//
//  AuthUser.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

public struct AuthUser: Codable, Sendable, Equatable {
    public let id: Int
    public let username: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String?

    public init(
        id: Int,
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
    }

    public var fullName: String { "\(firstName) \(lastName)" }
}
