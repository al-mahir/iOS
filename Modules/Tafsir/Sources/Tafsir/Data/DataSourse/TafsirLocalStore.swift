//
//  TafsirLocalStore.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import Foundation
public final class TafsirLocalStore: @unchecked Sendable {

    public static let shared = TafsirLocalStore()

    public var currentUserId: String? = nil

    private var registryKey: String {
        if let id = currentUserId, !id.isEmpty {
            return "com.app.tafsir.downloaded_registry_\(id)"
        }
        return "com.app.tafsir.downloaded_registry_guest"
    }

    private var primaryTafsirKeyDefaultsKey: String {
        if let id = currentUserId, !id.isEmpty {
            return "com.app.tafsir.primary_key_\(id)"
        }
        return "com.app.tafsir.primary_key_guest"
    }

    private let defaults: UserDefaults
    private let fileManager: FileManager

    public init(defaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.defaults = defaults
        self.fileManager = fileManager
        NotificationCenter.default.addObserver(forName: Notification.Name("com.almahir.userSessionDidChange"), object: nil, queue: .main) { [weak self] note in
            let userId = note.object as? String
            self?.currentUserId = userId
        }
    }

    /// The user's default tafsir source — shown first when long-pressing an ayah.
    /// Falls back to "ibn-kathir" until the user picks one in the management screen.
    public var primaryTafsirKey: String {
        get { defaults.string(forKey: primaryTafsirKeyDefaultsKey) ?? "ibn-kathir" }
        set { defaults.set(newValue, forKey: primaryTafsirKeyDefaultsKey) }
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var tafsirDirectory: URL {
        let folderName = currentUserId != nil && !currentUserId!.isEmpty ? "Tafsir_\(currentUserId!)" : "Tafsir_guest"
        let url = documentsDirectory.appendingPathComponent(folderName, isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    /// Destination path for a tafsir's downloaded file (used both to write and to read it).
    public func fileURL(for tafsirKey: String) -> URL {
        tafsirDirectory.appendingPathComponent("\(tafsirKey).json")
    }

    // MARK: - Registry

    private var registry: Set<String> {
        get { Set(defaults.stringArray(forKey: registryKey) ?? []) }
        set { defaults.set(Array(newValue), forKey: registryKey) }
    }

    public func isDownloaded(_ tafsirKey: String) -> Bool {
        registry.contains(tafsirKey) && fileManager.fileExists(atPath: fileURL(for: tafsirKey).path)
    }

    public func markDownloaded(_ tafsirKey: String) {
        var set = registry
        set.insert(tafsirKey)
        registry = set
    }

    private func markRemoved(_ tafsirKey: String) {
        var set = registry
        set.remove(tafsirKey)
        registry = set
    }

    // MARK: - File operations

    @discardableResult
    public func deleteFile(for tafsirKey: String) -> Bool {
        let url = fileURL(for: tafsirKey)
        guard fileManager.fileExists(atPath: url.path) else {
            markRemoved(tafsirKey)
            return true
        }
        do {
            try fileManager.removeItem(at: url)
            markRemoved(tafsirKey)
            return true
        } catch {
            return false
        }
    }
}
