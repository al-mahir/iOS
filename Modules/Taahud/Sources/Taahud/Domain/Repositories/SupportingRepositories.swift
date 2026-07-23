import Foundation

public enum MicrophonePermissionState: Sendable {
    case notDetermined
    case granted
    case denied
}

public protocol MicrophonePermissionRepository: Sendable {
    func currentState() -> MicrophonePermissionState
    /// Triggers the system prompt if `.notDetermined`; otherwise returns the
    /// current state without prompting again.
    func requestPermission() async -> MicrophonePermissionState
}

/// A single field from GET /moshaf-schema (API.md §6).
public struct MoshafFieldOption: Equatable, Sendable {
    public let value: MoshafValue
    public let label: String
}

public struct MoshafField: Equatable, Identifiable, Sendable {
    public var id: String { key }
    public let key: String
    public let nameAr: String
    public let description: String
    public let defaultValue: MoshafValue
    public let options: [MoshafFieldOption]
}

/// A single rule from GET /tajweed-rules (API.md §7).
public struct TajweedRuleOption: Equatable, Identifiable, Sendable {
    public var id: String { key }
    public let key: String
    public let nameAr: String
    public let nameEn: String
    public let kind: ErrorChannel // "tajweed" or "sifa"
}

public struct EngineHealth: Equatable, Sendable {
    public let defaultEngine: ASREngine
    public let availableEngines: [ASREngine]
}

/// GET /health, GET /moshaf-schema, GET /tajweed-rules — fetched once at app
/// start / settings-screen open per API.md §10 "Recommended flow".
public protocol TaahudSettingsRepository: Sendable {
    func fetchHealth() async throws -> EngineHealth
    func fetchMoshafSchema() async throws -> [MoshafField]
    func fetchTajweedRules() async throws -> [TajweedRuleOption]
}

/// Local persistence for completed sessions (story 14).
public protocol SessionHistoryRepository: Sendable {
    func save(_ summary: SessionSummary) async throws
    func fetchAll() async throws -> [SessionSummary]
    func fetch(id: String) async throws -> SessionSummary?
    func delete(id: String) async throws
}
