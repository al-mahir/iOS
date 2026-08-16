//
//  TestHistoryStore.swift
//  Test
//

import Foundation
import Combine

/// Keeps track of completed test sessions for the lifetime of the app run,
/// so `TestHubView` (in the Home module) can list them and re-open the
/// full result screen for any of them.
public final class TestHistoryStore: ObservableObject {
    public static let shared = TestHistoryStore()

    @Published public private(set) var entries: [TestHistoryEntry] = []

    private init() {}

    /// Records a finished test session. Newest results are shown first.
    public func record(_ result: TestSessionResult) {
        entries.insert(TestHistoryEntry(result: result), at: 0)
    }
}

public struct TestHistoryEntry: Identifiable, Hashable {
    public let id = UUID()
    public let completedAt: Date
    public let result: TestSessionResult

    public init(result: TestSessionResult, completedAt: Date = Date()) {
        self.result = result
        self.completedAt = completedAt
    }

    public static func == (lhs: TestHistoryEntry, rhs: TestHistoryEntry) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
