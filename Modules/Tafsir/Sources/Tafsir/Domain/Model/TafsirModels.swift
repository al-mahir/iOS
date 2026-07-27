//
//  TafsirModels.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import Foundation
import NetworkKit

public struct TafsirInfo: Identifiable, Equatable, Sendable {
    public var id: String { tafsirKey }

    public let tafsirKey: String
    public let displayName: String
    public let language: String
    public let languageName: String
    public let downloadUrl: String
    public let fileSizeBytes: Int64
    public var isDownloaded: Bool

    public init(
        tafsirKey: String,
        displayName: String,
        language: String,
        languageName: String,
        downloadUrl: String,
        fileSizeBytes: Int64,
        isDownloaded: Bool = false
    ) {
        self.tafsirKey = tafsirKey
        self.displayName = displayName
        self.language = language
        self.languageName = languageName
        self.downloadUrl = downloadUrl
        self.fileSizeBytes = fileSizeBytes
        self.isDownloaded = isDownloaded
    }
}

/// The interpretation text for one ayah (from GET /api/tafsir).
public struct AyahTafsir: Equatable, Sendable {
    public let surah: Int
    public let ayah: Int
    public let text: String

    public init(surah: Int, ayah: Int, text: String) {
        self.surah = surah
        self.ayah = ayah
        self.text = text
    }
}

/// Errors specific to downloading/removing a local tafsir file.
/// (Fetching JSON still surfaces `NetworkError` from NetworkKit.)
public enum TafsirDownloadError: Error, LocalizedError, Equatable {
    case invalidURL
    case network(NetworkError)
    case fileSystem(String)
    case notDownloaded

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The tafsir download link is invalid."
        case .network(let error):
            return error.errorDescription
        case .fileSystem(let message):
            return message
        case .notDownloaded:
            return "This tafsir hasn't been downloaded."
        }
    }

    public static func == (lhs: TafsirDownloadError, rhs: TafsirDownloadError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
