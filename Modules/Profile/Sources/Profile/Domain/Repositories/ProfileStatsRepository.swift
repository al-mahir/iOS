//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Foundation

public protocol ProfileStatsRepository {
    func getProfileStats() async throws -> ProfileStats
}
