//
//  ReadingProgress.swift
//  Common
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


//
//  ReadingProgressStore.swift
//  Common
//
//  Simple UserDefaults-backed "last read" position, shared across modules
//  without needing a database. Both Home (reads it for the dashboard card)
//  and Mushaf (writes it as the user reads) depend on Common, so this is
//  the natural shared home for it.
//

import Foundation

public struct ReadingProgress: Codable, Equatable {
    public let surahName: String
    public let surahNumber: Int
    public let pageNumber: Int
    public let ayahNumber: Int
    public let juzNumber: Int
    public let updatedAt: Date

    public init(surahName: String, surahNumber: Int, pageNumber: Int, ayahNumber: Int, juzNumber: Int, updatedAt: Date = Date()) {
        self.surahName = surahName
        self.surahNumber = surahNumber
        self.pageNumber = pageNumber
        self.ayahNumber = ayahNumber
        self.juzNumber = juzNumber
        self.updatedAt = updatedAt
    }

    /// Rough 0...1 progress through the mushaf by page count. Good enough
    /// for a progress bar; swap for an exact ayah-count-based calc later.
    public var progress: Double {
        min(1, Double(pageNumber) / 604.0)
    }
}

public final class ReadingProgressStore {
    public static let shared = ReadingProgressStore()

    private let key = "com.almahir.lastReadProgress"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func save(_ progress: ReadingProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: key)
    }

    /// nil means the user has never read anything yet — that's the signal
    /// Home uses to show "Start Exploring" instead of a resume card.
    public func load() -> ReadingProgress? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ReadingProgress.self, from: data)
    }
}