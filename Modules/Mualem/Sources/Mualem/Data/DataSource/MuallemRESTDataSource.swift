// MuallemRESTDataSource.swift
// Mualem

import Foundation

final class MuallemRESTDataSource {
    private var baseURL: String { MuallemSecrets.baseURL }
    private var token: String { MuallemSecrets.bearerToken }
    
    private func makeRequest(path: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            let errorMsg = NSLocalizedString("error_invalid_url", bundle: .module, value: "Invalid URL path", comment: "URL construction failure")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("true", forHTTPHeaderField: "ngrok-skip-browser-warning")
        return request
    }
    
    func fetchHealth() async throws -> HealthResponseDTO {
        let request = try makeRequest(path: "/health")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(HealthResponseDTO.self, from: data)
    }
    
    func fetchTajweedRules() async throws -> TajweedRulesResponseDTO {
        let request = try makeRequest(path: "/tajweed-rules")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TajweedRulesResponseDTO.self, from: data)
    }
    
    func fetchMoshafSchema() async throws -> MoshafSchemaResponseDTO {
        let request = try makeRequest(path: "/moshaf-schema")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(MoshafSchemaResponseDTO.self, from: data)
    }
}
