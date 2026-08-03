//
//  NotificationRepository.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Combine
import NetworkKit

public final class NotificationRepository: NotificationRepositoryProtocol, @unchecked Sendable {

    private let networkService: NetworkServiceProtocol
    private let mockDataSource: MockNotificationDataSource

    private let useMockData: Bool

    public init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        mockDataSource: MockNotificationDataSource = MockNotificationDataSource(),
        useMockData: Bool = true
    ) {
        self.networkService = networkService
        self.mockDataSource = mockDataSource
        self.useMockData = useMockData
    }

    public func getNotifications(userId: String) -> AnyPublisher<[Notification], NetworkError> {
        guard !useMockData else {
            return mockDataSource.getNotifications(userId: userId)
        }
        return networkService.request(NotificationEndpoint.list(userId: userId))
    }

    public func createNotification(
        userId: String,
        title: String,
        body: String,
        type: NotificationType
    ) -> AnyPublisher<Notification, NetworkError> {
        guard !useMockData else {
            return mockDataSource.createNotification(userId: userId, title: title, body: body, type: type)
        }
        let notification = Notification(userId: userId, title: title, body: body, type: type)
        return networkService.request(NotificationEndpoint.create(notification))
    }

    public func markAsRead(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        guard !useMockData else {
            return mockDataSource.markAsRead(notificationId: notificationId)
        }
        return networkService
            .requestWithoutData(NotificationEndpoint.markAsRead(id: notificationId))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func markAllAsRead(userId: String) -> AnyPublisher<Void, NetworkError> {
        guard !useMockData else {
            return mockDataSource.markAllAsRead(userId: userId)
        }
        return networkService
            .requestWithoutData(NotificationEndpoint.markAllAsRead(userId: userId))
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public func deleteNotification(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        guard !useMockData else {
            return mockDataSource.deleteNotification(notificationId: notificationId)
        }
        return networkService
            .requestWithoutData(NotificationEndpoint.delete(id: notificationId))
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
