//
//  SheikhMockData.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation

public enum SheikhMockData {

    public static let all: [Sheikh] = [
        Sheikh(
            id: "11111111-1111-1111-1111-111111111111",
            username: "sheikh_omar",
            firstName: "Omar",
            lastName: "Al-Fadel",
            email: "omar.alfadel@example.com",
            phoneNumber: "+20 100 000 0001",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 5.0
        ),
        Sheikh(
            id: "22222222-2222-2222-2222-222222222222",
            username: "sheikh_ayman",
            firstName: "Ayman",
            lastName: "Jad Al-Husseini",
            email: "ayman.jad@example.com",
            phoneNumber: "+20 100 000 0002",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.9
        ),
        Sheikh(
            id: "33333333-3333-3333-3333-333333333333",
            username: "sheikh_ibrahim",
            firstName: "Ibrahim",
            lastName: "Akram Al-Desouqi",
            email: "ibrahim.akram@example.com",
            phoneNumber: "+20 100 000 0003",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.8
        ),
        Sheikh(
            id: "44444444-4444-4444-4444-444444444444",
            username: "sheikh_ahmed_mousa",
            firstName: "Ahmed",
            lastName: "Mohammed Mousa Mohammed",
            email: "ahmed.mousa@example.com",
            phoneNumber: "+20 100 000 0004",
            profilePictureUrl: nil,
            sheikhStatus: .notAvailable,
            rate: 5.0
        ),
        Sheikh(
            id: "55555555-5555-5555-5555-555555555555",
            username: "sheikh_ahmed_wahib",
            firstName: "Ahmed",
            lastName: "Wahib Ibrahim Ali",
            email: "ahmed.wahib@example.com",
            phoneNumber: "+20 100 000 0005",
            profilePictureUrl: nil,
            sheikhStatus: .notAvailable,
            rate: 4.9
        ),
        Sheikh(
            id: "66666666-6666-6666-6666-666666666666",
            username: "sheikh_hassan",
            firstName: "Hassan",
            lastName: "Khalil",
            email: "hassan.khalil@example.com",
            phoneNumber: "+20 100 000 0006",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.7
        ),
        Sheikh(
            id: "77777777-7777-7777-7777-777777777777",
            username: "sheikh_yusuf",
            firstName: "Yusuf",
            lastName: "Al-Qaradawi",
            email: "yusuf.qaradawi@example.com",
            phoneNumber: "+20 100 000 0007",
            profilePictureUrl: nil,
            sheikhStatus: .available,
            rate: 4.6
        ),
        Sheikh(
            id: "88888888-8888-8888-8888-888888888888",
            username: "sheikh_mustafa",
            firstName: "Mustafa",
            lastName: "Al-Azhari",
            email: "mustafa.azhari@example.com",
            phoneNumber: "+20 100 000 0008",
            profilePictureUrl: nil,
            sheikhStatus: .notAvailable,
            rate: 4.5
        ),
    ]

    public static var available: [Sheikh] { all.filter { $0.isAvailable } }
    public static var inSession:  [Sheikh] { all.filter { !$0.isAvailable } }
    public static var first: Sheikh { all[0] }
}
