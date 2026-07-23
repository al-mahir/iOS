//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Foundation

class MockProfileStatsRepository: ProfileStatsRepository {
    func getProfileStats() async throws -> ProfileStats {
        // Simulate a one-second network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return ProfileStats(
            streak: StreakInfo(
                currentDays: 1,
                longestDays: 1,
                weekHistory: [false, false, false, true, false, false, false]
            ),
            sessionsCount: 2,
            achievements: [
                Achievement(title: "Started Memorizing", iconName: "brain.head.profile", colorType: .blue),
                Achievement(title: "Plan 1", iconName: "book.closed.fill", colorType: .yellow)
            ],
            pagesChart: [
                ChartData(label: "07-11", value: 80),
                ChartData(label: "07-12", value: 10),
                ChartData(label: "07-13", value: 5),
                ChartData(label: "07-14", value: 5)
            ],
            timeChart: [
                ChartData(label: "07-11", value: 60),
                ChartData(label: "07-12", value: 15),
                ChartData(label: "07-13", value: 10),
                ChartData(label: "07-14", value: 20)
            ],
            details: DetailedStats(
                totalTime: "0h 3m",
                khatmatCount: 0,
                readDaysCount: 0,
                versesReadCount: 0,
                earnedPages: 3,
                hasanatCount: "2.86K",
                searchUsageCount: 1,
                sharedVersesCount: 19
            )
        )
    }
}
