//
//  MockSheikhPackageRepository.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//
import Foundation

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
            throw NSError(domain: "MockRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated network failure."])
        }

        return mockData
    }

    public func cancelSubscription(id: String) async throws {
        try await Task.sleep(nanoseconds: simulatedDelay)

        if shouldFail {
            throw NSError(domain: "MockRepositoryError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to cancel subscription."])
        }

        if let index = mockData.firstIndex(where: { $0.id == id }) {
            mockData[index].status = .cancelled
        }
    }
}



public final class SheikhPackageRepository: SheikhPackageRepositoryProtocol {
    public init() {}

    public func fetchMySubscriptions() async throws -> [SheikhPackageSubscription] {
        // TODO: replace with real API call, e.g.
        // try await apiClient.get("/me/sheikh-subscriptions")
        return []
    }

    public func cancelSubscription(id: String) async throws {
        // TODO: replace with real API call, e.g.
        // try await apiClient.post("/subscriptions/\(id)/cancel")
    }
}
