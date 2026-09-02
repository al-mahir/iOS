//
//  SheikhReview.swift
//  Sheikh
//

import Foundation

public struct SheikhReview: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public let userName: String
    public let userInitials: String
    public let dateText: String
    public let rating: Double
    public let commentText: String

    public init(
        id: String,
        userName: String,
        userInitials: String,
        dateText: String,
        rating: Double,
        commentText: String
    ) {
        self.id = id
        self.userName = userName
        self.userInitials = userInitials
        self.dateText = dateText
        self.rating = rating
        self.commentText = commentText
    }
}
