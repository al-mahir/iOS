//
//  NotificationRepositoryProtocol.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Combine
import NetworkKit

public protocol NotificationRepositoryProtocol {
    func getNotifications(userId: String) -> AnyPublisher<[Notification], NetworkError>

    func createNotification(
        userId: String,
        title: String,
        body: String,
        type: NotificationType
    ) -> AnyPublisher<Notification, NetworkError>

    func markAsRead(notificationId: String) -> AnyPublisher<Void, NetworkError>
    func markAllAsRead(userId: String) -> AnyPublisher<Void, NetworkError>
    func deleteNotification(notificationId: String) -> AnyPublisher<Void, NetworkError>
}
