//
//  Notification.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation

public struct Notification: Codable, Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let title: String
    public let body: String
    public let type: NotificationType
    public let createdAt: Date
    public var isRead: Bool
    public var actionURL: String?
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        body: String,
        type: NotificationType,
        createdAt: Date = Date(),
        isRead: Bool = false,
        actionURL: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.type = type
        self.createdAt = createdAt
        self.isRead = isRead
        self.actionURL = actionURL
    }
}

public enum NotificationType: String, Codable, Sendable {
    case message = "MESSAGE"
    case reminder = "REMINDER"
    case update = "UPDATE"
    case alert = "ALERT"
    case achievement = "ACHIEVEMENT"
}
