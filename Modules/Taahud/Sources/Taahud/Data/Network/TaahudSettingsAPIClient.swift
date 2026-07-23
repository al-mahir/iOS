import Foundation

private struct HealthDTO: Decodable {
    let status: String
    let engine: String
    let available_engines: [String]
}

private struct MoshafOptionDTO: Decodable {
    let value: JSONValue
    let label: String
}

private struct MoshafFieldDTO: Decodable {
    let key: String
    let name_ar: String
    let description: String
    let `default`: JSONValue
    let options: [MoshafOptionDTO]
}

private struct MoshafSchemaDTO: Decodable {
    let fields: [MoshafFieldDTO]
}

private struct TajweedRuleDTO: Decodable {
    let key: String
    let name_ar: String
    let name_en: String
    let kind: String
}

private struct TajweedRulesDTO: Decodable {
    let rules: [TajweedRuleDTO]
}

/// `value`/`default` in moshaf-schema is a String or an Int (API.md §6);
/// decode either without failing the whole payload.
enum JSONValue: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func toMoshafValue() -> MoshafValue {
        switch self {
        case .string(let s): return .string(s)
        case .int(let i): return .int(i)
        }
    }
}

final class TaahudSettingsAPIClient: TaahudSettingsRepository, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchHealth() async throws -> EngineHealth {
        let dto: HealthDTO = try await get("health")
        return EngineHealth(
            defaultEngine: ASREngine(rawValue: dto.engine) ?? .mock,
            availableEngines: dto.available_engines.compactMap { ASREngine(rawValue: $0) }
        )
    }

    func fetchMoshafSchema() async throws -> [MoshafField] {
        let dto: MoshafSchemaDTO = try await get("moshaf-schema")
        return dto.fields.map { field in
            MoshafField(
                key: field.key,
                nameAr: field.name_ar,
                description: field.description,
                defaultValue: field.default.toMoshafValue(),
                options: field.options.map { MoshafFieldOption(value: $0.value.toMoshafValue(), label: $0.label) }
            )
        }
    }

    func fetchTajweedRules() async throws -> [TajweedRuleOption] {
        let dto: TajweedRulesDTO = try await get("tajweed-rules")
        return dto.rules.map {
            TajweedRuleOption(key: $0.key, nameAr: $0.name_ar, nameEn: $0.name_en, kind: ErrorChannel(rawValue: $0.kind) ?? .tajweed)
        }
    }

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
