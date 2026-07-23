//
//  SheikhSearchResult.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation

public struct SheikhSearchResult: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let profilePictureUrl: String?
    public let sheikhStatus: SheikhStatus
    public let rate: Double
    public let startIndex: Int?
    public let endIndex: Int?

    public init(
        id: String,
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        profilePictureUrl: String? = nil,
        sheikhStatus: SheikhStatus,
        rate: Double,
        startIndex: Int? = nil,
        endIndex: Int? = nil
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.profilePictureUrl = profilePictureUrl
        self.sheikhStatus = sheikhStatus
        self.rate = rate
        self.startIndex = startIndex
        self.endIndex = endIndex
    }

    public var fullName: String { "\(firstName) \(lastName)" }

    public var isAvailable: Bool { sheikhStatus == .available }

    public func toSheikh() -> Sheikh {
        Sheikh(
            id: id,
            username: username,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profilePictureUrl: profilePictureUrl,
            sheikhStatus: sheikhStatus,
            rate: rate
        )
    }
}
