//
//  MockNotificationDataSource.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Combine
import NetworkKit

public final class MockNotificationDataSource: @unchecked Sendable {

    private let lock = NSLock()
    private var storage: [Notification] = []
    private let simulatedLatency: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.4)

    public init() {}
    func getNotifications(userId: String) -> AnyPublisher<[Notification], NetworkError> {
        lock.lock()
        if !storage.contains(where: { $0.userId == userId }) {
            storage.append(contentsOf: Self.sampleData(for: userId))
        }
        let result = storage
            .filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
        lock.unlock()

        return respond(with: result)
    }

    func createNotification(
        userId: String,
        title: String,
        body: String,
        type: NotificationType
    ) -> AnyPublisher<Notification, NetworkError> {
        let notification = Notification(userId: userId, title: title, body: body, type: type)
        lock.lock()
        storage.insert(notification, at: 0)
        lock.unlock()
        return respond(with: notification)
    }

    func markAsRead(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        lock.lock()
        if let index = storage.firstIndex(where: { $0.id == notificationId }) {
            storage[index].isRead = true
        }
        lock.unlock()
        return respond(with: ())
    }

    func markAllAsRead(userId: String) -> AnyPublisher<Void, NetworkError> {
        lock.lock()
        for index in storage.indices where storage[index].userId == userId {
            storage[index].isRead = true
        }
        lock.unlock()
        return respond(with: ())
    }

    func deleteNotification(notificationId: String) -> AnyPublisher<Void, NetworkError> {
        lock.lock()
        storage.removeAll { $0.id == notificationId }
        lock.unlock()
        return respond(with: ())
    }

    // MARK: - Helpers

    private func respond<T>(with value: T) -> AnyPublisher<T, NetworkError> {
        Just(value)
            .setFailureType(to: NetworkError.self)
            .delay(for: simulatedLatency, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private static func sampleData(for userId: String) -> [Notification] {
        let now = Date()
        return [
//            Notification(
//                userId: userId,
//                title: "Welcome!",
//                body: "Thanks for joining — pick up where you left off any time.",
//                type: .message,
//                createdAt: now.addingTimeInterval(-60 * 5)
//            ),
//            Notification(
//                userId: userId,
//                title: "Daily Reminder",
//                body: "You haven't hit today's reading goal yet.",
//                type: .reminder,
//                createdAt: now.addingTimeInterval(-3600),
//                isRead: true
//            ),
//            Notification(
//                userId: userId,
//                title: "New Feature",
//                body: "Tafsir is now available for offline download.",
//                type: .update,
//                createdAt: now.addingTimeInterval(-86400)
//            ),
//            Notification(
//                userId: userId,
//                title: "Streak Achieved!",
//                body: "7 days in a row — keep it going.",
//                type: .achievement,
//                createdAt: now.addingTimeInterval(-172_800),
//                isRead: true
//            )
        ]
    }
}
