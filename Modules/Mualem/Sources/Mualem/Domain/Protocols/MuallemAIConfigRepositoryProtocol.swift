//
//  MuallemAIConfigRepositoryProtocol.swift
//  Mualem
//
//  Domain contract for AI service configuration (REST endpoints).
//

import Foundation

public protocol MuallemAIConfigRepositoryProtocol {
    /// Fetches the AI service health status and available engines.
    func fetchHealth() async throws -> AIHealthInfo
    
    /// Fetches the list of tajweed rules available for grading.
    func fetchTajweedRules() async throws -> [TajweedRuleConfig]
    
    /// Fetches the moshaf schema fields for recitation settings.
    func fetchMoshafSchema() async throws -> [MoshafSchemaField]
}
