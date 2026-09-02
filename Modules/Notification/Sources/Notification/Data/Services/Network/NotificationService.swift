//
//  NotificationService.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Authentication
import NetworkKit
import Combine

@MainActor
public final class NotificationService: ObservableObject {

    @Published public private(set) var currentUserId: String?
    @Published public private(set) var notifications: [Notification] = []
    @Published public private(set) var isLoading = false
    @Published public var errorMessage: String?

    public var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let authManager: AuthManager
    private let useCases: NotificationUseCases
    private var cancellables = Set<AnyCancellable>()

    public init(
        authManager: AuthManager = .shared,
        useCases: NotificationUseCases = NotificationDIContainer.shared.resolve(NotificationUseCases.self)
    ) {
        self.authManager = authManager
        self.useCases = useCases
        observeAuthChanges()
    }

    private func observeAuthChanges() {
        authManager.$authState
            .sink { [weak self] state in
                guard let self else { return }
                if case .authenticated(let user) = state {
                    self.currentUserId = user.id
                    self.loadNotifications()
                } else {
                    self.currentUserId = nil
                    self.notifications = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Load

    public func loadNotifications() {
        guard let userId = currentUserId else { return }
        isLoading = true
        errorMessage = nil
        useCases.getNotifications.execute(userId: userId)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] notifications in
                self?.notifications = notifications
            }
            .store(in: &cancellables)
    }

    // MARK: - Create

    public func createNotification(title: String, body: String, type: NotificationType) {
        guard let userId = currentUserId else {
            errorMessage = "No user logged in."
            return
        }
        useCases.createNotification.execute(userId: userId, title: title, body: body, type: type)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] notification in
                self?.notifications.insert(notification, at: 0)
            }
            .store(in: &cancellables)
    }

    // MARK: - Mark as read

    public func markAsRead(_ notification: Notification) {
        guard !notification.isRead else { return }
        useCases.markAsRead.execute(notificationId: notification.id)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] in
                self?.setReadState(notificationId: notification.id, isRead: true)
            }
            .store(in: &cancellables)
    }

    public func markAllAsRead() {
        guard let userId = currentUserId, unreadCount > 0 else { return }
        useCases.markAllAsRead.execute(userId: userId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                for index in self.notifications.indices {
                    self.notifications[index].isRead = true
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Delete

    public func delete(_ notification: Notification) {
        useCases.deleteNotification.execute(notificationId: notification.id)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] in
                self?.notifications.removeAll { $0.id == notification.id }
            }
            .store(in: &cancellables)
    }

    // MARK: - Private helpers

    private func setReadState(notificationId: String, isRead: Bool) {
        guard let index = notifications.firstIndex(where: { $0.id == notificationId }) else { return }
        notifications[index].isRead = isRead
    }
}
