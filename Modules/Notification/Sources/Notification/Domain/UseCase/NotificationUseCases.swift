//
//  NotificationUseCases.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Combine
import NetworkKit

public struct GetNotificationsUseCase {
    private let repository: NotificationRepositoryProtocol

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userId: String) -> AnyPublisher<[Notification], NetworkError> {
        repository.getNotifications(userId: userId)
    }
}

public struct CreateNotificationUseCase {
    private let repository: NotificationRepositoryProtocol

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        userId: String,
        title: String,
        body: String,
        type: NotificationType
    ) -> AnyPublisher<Notification, NetworkError> {
        repository.createNotification(userId: userId, title: title, body: body, type: type)
    }
}

public struct MarkNotificationAsReadUseCase {
    private let repository: NotificationRepositoryProtocol

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        repository.markAsRead(notificationId: notificationId)
    }
}

public struct MarkAllNotificationsAsReadUseCase {
    private let repository: NotificationRepositoryProtocol

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userId: String) -> AnyPublisher<Void, NetworkError> {
        repository.markAllAsRead(userId: userId)
    }
}

public struct DeleteNotificationUseCase {
    private let repository: NotificationRepositoryProtocol

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        repository.deleteNotification(notificationId: notificationId)
    }
}

public struct NotificationUseCases {
    public let repository: NotificationRepositoryProtocol

    public let getNotifications: GetNotificationsUseCase
    public let createNotification: CreateNotificationUseCase
    public let markAsRead: MarkNotificationAsReadUseCase
    public let markAllAsRead: MarkAllNotificationsAsReadUseCase
    public let deleteNotification: DeleteNotificationUseCase

    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
        self.getNotifications = GetNotificationsUseCase(repository: repository)
        self.createNotification = CreateNotificationUseCase(repository: repository)
        self.markAsRead = MarkNotificationAsReadUseCase(repository: repository)
        self.markAllAsRead = MarkAllNotificationsAsReadUseCase(repository: repository)
        self.deleteNotification = DeleteNotificationUseCase(repository: repository)
    }
}
