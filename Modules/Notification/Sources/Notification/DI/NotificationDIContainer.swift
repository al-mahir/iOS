//
//  NotificationDIContainer.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation

public final class NotificationDIContainer: @unchecked Sendable {

    public static let shared = NotificationDIContainer()

    private init() {}

    private lazy var repository: NotificationRepositoryProtocol = NotificationRepository()
    private lazy var useCases = NotificationUseCases(repository: repository)

    public func resolve(_ type: NotificationUseCases.Type) -> NotificationUseCases {
        useCases
    }

    @MainActor
    public func resolve(_ type: NotificationService.Type) -> NotificationService {
        NotificationService(useCases: useCases)
    }
}
