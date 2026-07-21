//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Foundation

public struct GetProfileStatsUseCase {
    public let repository: ProfileStatsRepository
    
    public init(repository: ProfileStatsRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> ProfileStats {
        return try await repository.getProfileStats()
    }
}
