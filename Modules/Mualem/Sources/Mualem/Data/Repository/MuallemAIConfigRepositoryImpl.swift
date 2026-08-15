// MuallemAIConfigRepositoryImpl.swift
// Mualem

import Foundation

final class MuallemAIConfigRepositoryImpl: MuallemAIConfigRepositoryProtocol {
    private let restDataSource: MuallemRESTDataSource
    private let mockDataSource: MuallemMockDataSource
    private var cachedHealth: AIHealthInfo?
    private var cachedRules: [TajweedRuleConfig]?
    
    init(restDataSource: MuallemRESTDataSource = MuallemRESTDataSource(),
         mockDataSource: MuallemMockDataSource = MuallemMockDataSource()) {
        self.restDataSource = restDataSource
        self.mockDataSource = mockDataSource
    }
    
    func fetchHealth() async throws -> AIHealthInfo {
        if let cached = cachedHealth { return cached }
        
        do {
            let dto = try await restDataSource.fetchHealth()
            let info = AIConfigMapper.mapHealth(dto)
            self.cachedHealth = info
            return info
        } catch {
            let info = mockDataSource.mockHealth()
            self.cachedHealth = info
            return info
        }
    }
    
    func fetchTajweedRules() async throws -> [TajweedRuleConfig] {
        if let cached = cachedRules { return cached }
        
        do {
            let dto = try await restDataSource.fetchTajweedRules()
            let rules = AIConfigMapper.mapRules(dto)
            self.cachedRules = rules
            return rules
        } catch {
            let rules = mockDataSource.mockTajweedRules()
            self.cachedRules = rules
            return rules
        }
    }
    
    func fetchMoshafSchema() async throws -> [MoshafSchemaField] {
        do {
            let dto = try await restDataSource.fetchMoshafSchema()
            return AIConfigMapper.mapSchema(dto)
        } catch {
            return mockDataSource.mockMoshafSchema()
        }
    }
}
