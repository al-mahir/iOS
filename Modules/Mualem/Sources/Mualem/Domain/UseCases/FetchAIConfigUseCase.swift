//
//  FetchAIConfigUseCase.swift
//  Mualem
//
//  Fetches AI health + tajweed rules for the setup screen.
//

import Foundation

public final class FetchAIConfigUseCase {
    private let repository: MuallemAIConfigRepositoryProtocol
    
    public init(repository: MuallemAIConfigRepositoryProtocol) {
        self.repository = repository
    }
    
    /// Fetches the AI service health.
    public func fetchHealth() async throws -> AIHealthInfo {
        try await repository.fetchHealth()
    }
    
    /// Fetches the available tajweed rules.
    public func fetchTajweedRules() async throws -> [TajweedRuleConfig] {
        try await repository.fetchTajweedRules()
    }
    
    /// Fetches the moshaf schema fields.
    public func fetchMoshafSchema() async throws -> [MoshafSchemaField] {
        try await repository.fetchMoshafSchema()
    }
}
