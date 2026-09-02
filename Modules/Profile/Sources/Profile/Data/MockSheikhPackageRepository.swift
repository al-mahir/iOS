//
//  MockSheikhPackageRepository.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//

import Foundation
import Payment

public final class MockSheikhPackageRepository: SheikhPackageRepositoryProtocol {
    private var mockData: [SheikhPackageSubscription]
    private let simulatedDelay: UInt64
    private let shouldFail: Bool

    public init(
        subscriptions: [SheikhPackageSubscription] = SheikhPackageSubscription.mockList,
        simulatedDelaySeconds: Double = 0.8,
        shouldFail: Bool = false
    ) {
        self.mockData = subscriptions
        self.simulatedDelay = UInt64(simulatedDelaySeconds * 1_000_000_000)
        self.shouldFail = shouldFail
    }

    public func fetchMySubscriptions() async throws -> [SheikhPackageSubscription] {
        try await Task.sleep(nanoseconds: simulatedDelay)

        if shouldFail {
            throw NSError(
                domain: "MockRepositoryError",
                code: 500,
                userInfo: [
                    NSLocalizedDescriptionKey: String(
                        localized: "Simulated network failure.",
                        bundle: .module
                    )
                ]
            )
        }

        return mockData
    }

    public func cancelSubscription(id: String) async throws {
        try await Task.sleep(nanoseconds: simulatedDelay)

        if shouldFail {
            throw NSError(
                domain: "MockRepositoryError",
                code: 400,
                userInfo: [
                    NSLocalizedDescriptionKey: String(
                        localized: "Failed to cancel subscription.",
                        bundle: .module
                    )
                ]
            )
        }

        if let index = mockData.firstIndex(where: { $0.id == id }) {
            mockData[index].status = .cancelled
        }
    }
}


public final class SheikhPackageRepository: SheikhPackageRepositoryProtocol {
    public init() {}

    public func fetchMySubscriptions() async throws -> [SheikhPackageSubscription] {
        // Convert in-memory payment store → profile subscriptions
        let stored = SubscriptionStore.shared.subscriptions.map { active in
            SheikhPackageSubscription(
                id: active.id,
                sheikhId: "local",
                sheikhName: active.reciterName,
                sheikhImageUrl: nil,
                packageName: active.packageTitle,
                price: NSDecimalNumber(decimal: active.price).doubleValue,
                currencyCode: active.currencyCode,
                totalSessions: 8,          // default — update when backend provides it
                usedSessions: 0,
                startDate: active.startDate,
                endDate: active.endDate,
                status: active.status.toPackageStatus()
            )
        }
        // TODO: merge with real API response once backend subscriptions endpoint is ready
        return stored
    }

    public func cancelSubscription(id: String) async throws {
        SubscriptionStore.shared.cancelSubscription(id: id)
    }
}

// MARK: - SubscriptionStatus → SheikhPackageStatus

private extension SubscriptionStatus {
    func toPackageStatus() -> SheikhPackageStatus {
        switch self {
        case .active:    return .active
        case .expired:   return .expired
        case .cancelled: return .cancelled
        }
    }
}
