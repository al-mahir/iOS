//
//  ReadingProgress.swift
//  Common
//
//  Created by Alaa Ayman on 07/02/1448 AH.
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

extension Notification.Name {
    public static let readingProgressDidChange = Notification.Name("com.almahir.readingProgressDidChange")
    public static let userSessionDidChange = Notification.Name("com.almahir.userSessionDidChange")
}

public final class ReadingProgressStore {
    public static let shared = ReadingProgressStore()

    public var currentUserId: String? = nil {
        didSet {
            NotificationCenter.default.post(name: .readingProgressDidChange, object: load())
        }
    }

    private func storageKey(for userId: String?) -> String {
        if let id = userId, !id.isEmpty {
            return "com.almahir.lastReadProgress.\(id)"
        }
        return "com.almahir.lastReadProgress.guest"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        NotificationCenter.default.addObserver(forName: .userSessionDidChange, object: nil, queue: .main) { [weak self] note in
            let userId = note.object as? String
            self?.currentUserId = userId
        }
    }

    public func save(_ progress: ReadingProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: storageKey(for: currentUserId))
        NotificationCenter.default.post(name: .readingProgressDidChange, object: progress)
    }

    /// nil means the user has never read anything yet — that's the signal
    /// Home uses to show "Start Exploring" instead of a resume card.
    public func load() -> ReadingProgress? {
        guard let data = defaults.data(forKey: storageKey(for: currentUserId)) else { return nil }
        return try? JSONDecoder().decode(ReadingProgress.self, from: data)
    }

    public func clear() {
        defaults.removeObject(forKey: storageKey(for: currentUserId))
        NotificationCenter.default.post(name: .readingProgressDidChange, object: nil)
    }
}

