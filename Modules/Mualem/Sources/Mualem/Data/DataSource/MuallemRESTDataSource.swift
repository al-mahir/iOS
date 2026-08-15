// MuallemRESTDataSource.swift
// Mualem

import Foundation

final class MuallemRESTDataSource {
    private var baseURL: String { MuallemSecrets.baseURL }
    private var token: String { MuallemSecrets.bearerToken }
    
    private func makeRequest(path: String) -> URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")
        return request
    }
    
    func fetchHealth() async throws -> HealthResponseDTO {
        let (data, _) = try await URLSession.shared.data(for: makeRequest(path: "/health"))
        return try JSONDecoder().decode(HealthResponseDTO.self, from: data)
    }
    
    func fetchTajweedRules() async throws -> TajweedRulesResponseDTO {
        let (data, _) = try await URLSession.shared.data(for: makeRequest(path: "/tajweed-rules"))
        return try JSONDecoder().decode(TajweedRulesResponseDTO.self, from: data)
    }
    
    func fetchMoshafSchema() async throws -> MoshafSchemaResponseDTO {
        let (data, _) = try await URLSession.shared.data(for: makeRequest(path: "/moshaf-schema"))
        return try JSONDecoder().decode(MoshafSchemaResponseDTO.self, from: data)
    }
}
