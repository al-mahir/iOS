//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Foundation

public struct ProfileStats {
    public let streak: StreakInfo
    public let sessionsCount: Int
    public let achievements: [Achievement]
    public let pagesChart: [ChartData]
    public let timeChart: [ChartData]
    public let details: DetailedStats
    
    public init(streak: StreakInfo, sessionsCount: Int, achievements: [Achievement], pagesChart: [ChartData], timeChart: [ChartData], details: DetailedStats) {
        self.streak = streak
        self.sessionsCount = sessionsCount
        self.achievements = achievements
        self.pagesChart = pagesChart
        self.timeChart = timeChart
        self.details = details
    }
}

public struct StreakInfo {
    public let currentDays: Int
    public let longestDays: Int
    public let weekHistory: [Bool]
    
    public init(currentDays: Int, longestDays: Int, weekHistory: [Bool]) {
        self.currentDays = currentDays
        self.longestDays = longestDays
        self.weekHistory = weekHistory
    }
}

public struct Achievement: Identifiable {
    public let id: UUID
    public let title: String
    public let iconName: String
    public let colorType: AchievementColor
    
    public enum AchievementColor {
        case blue, yellow, pink
    }
    
    public init(id: UUID = UUID(), title: String, iconName: String, colorType: AchievementColor) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorType = colorType
    }
}

public struct ChartData: Identifiable {
    public let id: UUID
    public let label: String
    public let value: Double
    
    public init(id: UUID = UUID(), label: String, value: Double) {
        self.id = id
        self.label = label
        self.value = value
    }
}

public struct DetailedStats {
    public let totalTime: String
    public let khatmatCount: Int
    public let readDaysCount: Int
    public let versesReadCount: Int
    public let earnedPages: Int
    public let hasanatCount: String
    public let searchUsageCount: Int
    public let sharedVersesCount: Int
    
    public init(totalTime: String, khatmatCount: Int, readDaysCount: Int, versesReadCount: Int, earnedPages: Int, hasanatCount: String, searchUsageCount: Int, sharedVersesCount: Int) {
        self.totalTime = totalTime
        self.khatmatCount = khatmatCount
        self.readDaysCount = readDaysCount
        self.versesReadCount = versesReadCount
        self.earnedPages = earnedPages
        self.hasanatCount = hasanatCount
        self.searchUsageCount = searchUsageCount
        self.sharedVersesCount = sharedVersesCount
    }
}
