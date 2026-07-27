//
//  SessionUser.swift
//  Common
//
//  Created for Session Management.
//

import Foundation

public struct SessionUser: Codable, Equatable, Sendable {
    public let id: String
    public let username: String
    public let email: String
    public let fullName: String
    public let profilePictureUrl: String?

    public init(
        id: String,
        username: String,
        email: String,
        fullName: String,
        profilePictureUrl: String? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.fullName = fullName
        self.profilePictureUrl = profilePictureUrl
    }
}
