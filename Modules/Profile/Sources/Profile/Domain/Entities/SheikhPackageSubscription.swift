//
//  SheikhPackageSubscription.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//

import Foundation

public enum SheikhPackageStatus: String, Codable {
    case active
    case expired
    case cancelled

    var displayLabel: String {
        switch self {
        case .active: return "Active"
        case .expired: return "Expired"
        case .cancelled: return "Cancelled"
        }
    }
}

public struct SheikhPackageSubscription: Identifiable, Codable, Equatable {
    public let id: String
    public let sheikhId: String
    public let sheikhName: String
    public let sheikhImageUrl: String?
    public let packageName: String        // e.g. "12 Sessions"
    public let price: Double              // e.g. 120
    public let currencyCode: String       // e.g. "EGP"
    public let totalSessions: Int
    public let usedSessions: Int
    public let startDate: Date
    public let endDate: Date
    public var status: SheikhPackageStatus

    public var sessionsRemaining: Int {
        max(totalSessions - usedSessions, 0)
    }

    public var progress: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(usedSessions) / Double(totalSessions)
    }

    public var isActive: Bool {
        status == .active
    }

    public init(
        id: String,
        sheikhId: String,
        sheikhName: String,
        sheikhImageUrl: String? = nil,
        packageName: String,
        price: Double,
        currencyCode: String = "EGP",
        totalSessions: Int,
        usedSessions: Int,
        startDate: Date,
        endDate: Date,
        status: SheikhPackageStatus
    ) {
        self.id = id
        self.sheikhId = sheikhId
        self.sheikhName = sheikhName
        self.sheikhImageUrl = sheikhImageUrl
        self.packageName = packageName
        self.price = price
        self.currencyCode = currencyCode
        self.totalSessions = totalSessions
        self.usedSessions = usedSessions
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
    }
}

extension SheikhPackageSubscription {
    public static let mockList: [SheikhPackageSubscription] = [
        SheikhPackageSubscription(
            id: "sub_001",
            sheikhId: "shk_omar",
            sheikhName: "Sheikh Omar Abdelkafy",
            sheikhImageUrl: nil,
            packageName: "12 Sessions – Tajweed",
            price: 120.0,
            currencyCode: "EGP",
            totalSessions: 12,
            usedSessions: 9,
            startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
            status: .active
        ),
        SheikhPackageSubscription(
            id: "sub_002",
            sheikhId: "shk_hassan",
            sheikhName: "Sheikh Hassan Al-Banna",
            sheikhImageUrl: nil,
            packageName: "8 Sessions – Hifz & Revision",
            price: 200.0,
            currencyCode: "EGP",
            totalSessions: 8,
            usedSessions: 2,
            startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date(),
            status: .active
        ),
        SheikhPackageSubscription(
            id: "sub_003",
            sheikhId: "shk_mahmoud",
            sheikhName: "Sheikh Mahmoud Al-Hussary",
            sheikhImageUrl: nil,
            packageName: "4 Sessions – Ijazah Foundation",
            price: 150.0,
            currencyCode: "EGP",
            totalSessions: 4,
            usedSessions: 4,
            startDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            status: .expired
        ),
        SheikhPackageSubscription(
            id: "sub_004",
            sheikhId: "shk_yasser",
            sheikhName: "Sheikh Yasser Al-Dousari",
            sheikhImageUrl: nil,
            packageName: "6 Sessions – Tilawah Practice",
            price: 90.0,
            currencyCode: "EGP",
            totalSessions: 6,
            usedSessions: 1,
            startDate: Calendar.current.date(byAdding: .month, value: -4, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
            status: .cancelled
        )
    ]
}
