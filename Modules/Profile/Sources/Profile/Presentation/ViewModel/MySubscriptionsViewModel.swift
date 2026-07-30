//
//  MySubscriptionsViewModel.swift
//  Profile
//

import Foundation
import SwiftUI

@MainActor
public final class MySubscriptionsViewModel: ObservableObject {
    @Published public private(set) var subscriptions: [SheikhPackageSubscription] = []
    @Published public private(set) var isLoading = false
    @Published public var errorMessage: String?
    @Published public var pendingCancelSubscription: SheikhPackageSubscription?
    @Published public var isCancelling = false

    public var activeSubscriptions: [SheikhPackageSubscription] {
        subscriptions.filter { $0.status == .active }
    }

    public var pastSubscriptions: [SheikhPackageSubscription] {
        subscriptions.filter { $0.status != .active }
    }

    public var activeCount: Int { activeSubscriptions.count }

    private let repository: SheikhPackageRepositoryProtocol

    nonisolated public init(repository: SheikhPackageRepositoryProtocol = SheikhPackageRepository()) {
        self.repository = repository
    }

    public func loadSubscriptions() async {
        isLoading = true
        errorMessage = nil
        do {
            subscriptions = try await repository.fetchMySubscriptions()
        } catch {
            errorMessage = "Couldn't load your subscriptions. Please try again."
        }
        isLoading = false
    }

    public func requestCancel(_ subscription: SheikhPackageSubscription) {
        pendingCancelSubscription = subscription
    }

    public func confirmCancel() async {
        guard let subscription = pendingCancelSubscription else { return }
        isCancelling = true
        do {
            try await repository.cancelSubscription(id: subscription.id)
            if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                subscriptions[index].status = .cancelled
            }
        } catch {
            errorMessage = "Couldn't cancel this package. Please try again."
        }
        isCancelling = false
        pendingCancelSubscription = nil
    }
}


