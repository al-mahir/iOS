//
//  SubscriptionStore.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation

/// Shared in-memory store that holds subscriptions created after successful payments.
/// Payment writes to it; Profile reads from it.
/// When backend has a real subscriptions API, this store can be removed.
public final class SubscriptionStore: @unchecked Sendable {

    // MARK: Shared Instance

    public static let shared = SubscriptionStore()
    private init() {}

    // MARK: Storage

    private var _subscriptions: [ActiveSubscription] = []
    private let lock = NSLock()

    // MARK: Public Interface

    public var subscriptions: [ActiveSubscription] {
        lock.withLock { _subscriptions }
    }

    public func add(_ subscription: ActiveSubscription) {
        lock.withLock {
            // Avoid duplicates by transactionID
            if !_subscriptions.contains(where: { $0.transactionID == subscription.transactionID }) {
                _subscriptions.insert(subscription, at: 0)
            }
        }
    }

    public func cancelSubscription(id: String) {
        lock.withLock {
            if let index = _subscriptions.firstIndex(where: { $0.id == id }) {
                _subscriptions[index].status = .cancelled
            }
        }
    }
}

// MARK: - ActiveSubscription

/// A subscription created locally after a successful payment.
public struct ActiveSubscription: Identifiable, Sendable {
    public let id: String               // UUID string
    public let transactionID: String
    public let packageTitle: String
    public let packageSubtitle: String  // e.g. "2 sessions/week"
    public let price: Decimal
    public let currencyCode: String
    public let reciterName: String
    public let startDate: Date
    public let endDate: Date            // startDate + 30 days
    public var status: SubscriptionStatus

    public init(
        id: String = UUID().uuidString,
        transactionID: String,
        packageTitle: String,
        packageSubtitle: String,
        price: Decimal,
        currencyCode: String = "EGP",
        reciterName: String,
        startDate: Date = Date(),
        endDate: Date,
        status: SubscriptionStatus = .active
    ) {
        self.id = id
        self.transactionID = transactionID
        self.packageTitle = packageTitle
        self.packageSubtitle = packageSubtitle
        self.price = price
        self.currencyCode = currencyCode
        self.reciterName = reciterName
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
    }

    public var formattedPrice: String {
        "\(NSDecimalNumber(decimal: price).stringValue) \(currencyCode)"
    }
}

// MARK: - SubscriptionStatus

public enum SubscriptionStatus: String, Sendable {
    case active
    case expired
    case cancelled

    public var displayLabel: String {
        switch self {
        case .active: return "Active"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        }
    }
}
