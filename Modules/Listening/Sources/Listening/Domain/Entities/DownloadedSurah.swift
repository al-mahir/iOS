//
//  DownloadedSurah.swift
//  Listening
//

import Foundation

/// Entity representing a downloaded Quran surah audio and word timings.
public struct DownloadedSurah: Identifiable, Codable, Hashable, Sendable {
    public var id: String { "\(reciterId)_\(surahNumber)" }

    public let reciterId: Int
    public let reciterName: String
    public let reciterArabicName: String
    public let surahNumber: Int
    public let surahName: String
    public let fileSize: Int64
    public let audioFileName: String
    public let timingsFileName: String
    public let downloadedAt: Date

    public init(
        reciterId: Int,
        reciterName: String,
        reciterArabicName: String,
        surahNumber: Int,
        surahName: String,
        fileSize: Int64,
        audioFileName: String,
        timingsFileName: String,
        downloadedAt: Date = Date()
    ) {
        self.reciterId = reciterId
        self.reciterName = reciterName
        self.reciterArabicName = reciterArabicName
        self.surahNumber = surahNumber
        self.surahName = surahName
        self.fileSize = fileSize
        self.audioFileName = audioFileName
        self.timingsFileName = timingsFileName
        self.downloadedAt = downloadedAt
    }

    /// Formatted string representing the file size, e.g. "12.4 MB"
    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}
