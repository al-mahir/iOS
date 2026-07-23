//
//  Sheikh.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation

public enum SheikhStatus: String, Codable, Sendable {
    case available = "AVAILABLE"
    case notAvailable = "NOT_AVAILABLE"
}

public struct Sheikh: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String?
    public let profilePictureUrl: String?
    public let sheikhStatus: SheikhStatus
    public let rate: Double

    public init(
        id: String,
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil,
        profilePictureUrl: String? = nil,
        sheikhStatus: SheikhStatus,
        rate: Double
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePictureUrl = profilePictureUrl
        self.sheikhStatus = sheikhStatus
        self.rate = rate
    }

    public var fullName: String { "\(firstName) \(lastName)" }

    public var isAvailable: Bool { sheikhStatus == .available }
}
