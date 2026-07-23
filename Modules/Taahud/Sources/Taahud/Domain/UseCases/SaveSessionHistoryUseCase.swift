import Foundation

/// Story 14: Save Session History.
public struct SaveSessionHistoryUseCase: Sendable {
    private let repository: SessionHistoryRepository
    public init(repository: SessionHistoryRepository) { self.repository = repository }

    public func execute(_ summary: SessionSummary) async throws {
        try await repository.save(summary)
    }
}

/// Supports story 11/12 re-entry: pulling past sessions for review.
public struct FetchSessionHistoryUseCase: Sendable {
    private let repository: SessionHistoryRepository
    public init(repository: SessionHistoryRepository) { self.repository = repository }

    public func executeAll() async throws -> [SessionSummary] {
        try await repository.fetchAll()
    }

    public func execute(id: String) async throws -> SessionSummary? {
        try await repository.fetch(id: id)
    }
}
