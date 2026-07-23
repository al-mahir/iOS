//
//  AuthUser.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation

public struct AuthUser: Codable, Sendable, Equatable {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String?
    public let profilePictureUrl: String?
    public let provider: String?
    public let roles: [String]?

    public init(
        id: String,
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil,
        profilePictureUrl: String? = nil,
        provider: String? = nil,
        roles: [String]? = nil
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePictureUrl = profilePictureUrl
        self.provider = provider
        self.roles = roles
    }

    public var fullName: String { "\(firstName) \(lastName)" }
}
