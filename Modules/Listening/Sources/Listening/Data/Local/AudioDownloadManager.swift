//
//  AudioDownloadManager.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

/// Central manager responsible for downloading, persisting, and deleting reciter surah audio and word timings.
@MainActor
public final class AudioDownloadManager: NSObject, ObservableObject {

    public static let shared = AudioDownloadManager()

    // MARK: - Published State

    @Published public private(set) var downloads: [DownloadedSurah] = []
    @Published public private(set) var activeDownloads: [String: Double] = [:] // key: "reciterId_surahNumber", value: progress 0.0 - 1.0
    @Published public private(set) var downloadErrors: [String: String] = [:]
    @Published public var currentUserId: String? = nil {
        didSet {
            loadPersistedRegistry()
        }
    }

    // MARK: - Storage Keys & Paths

    private var userStorageKey: String {
        if let id = currentUserId, !id.isEmpty {
            return "com.almahir.offline_audio_downloads_\(id)"
        }
        return "com.almahir.offline_audio_downloads_guest"
    }

    private var baseFolderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderName = currentUserId != nil && !currentUserId!.isEmpty ? "OfflineAudio_\(currentUserId!)" : "OfflineAudio_guest"
        let folder = docs.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    private let networkService: NetworkServiceProtocol
    private var downloadTasks: [String: URLSessionDownloadTask] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    public init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        super.init()
        NotificationCenter.default.addObserver(forName: Notification.Name("com.almahir.userSessionDidChange"), object: nil, queue: .main) { [weak self] note in
            let userId = note.object as? String
            self?.currentUserId = userId
        }
        loadPersistedRegistry()
    }

    // MARK: - Query API

    /// Check if a specific surah audio is downloaded locally
    public func isSurahDownloaded(reciterId: Int, surahNumber: Int) -> Bool {
        let key = "\(reciterId)_\(surahNumber)"
        guard downloads.contains(where: { $0.id == key }) else { return false }
        let (audioURL, _) = getFilePaths(reciterId: reciterId, surahNumber: surahNumber)
        return FileManager.default.fileExists(atPath: audioURL.path)
    }

    /// Retrieve local audio file URL and decoded word timings if available
    public func getLocalAudioAndTimings(reciterId: Int, surahNumber: Int) -> (audioURL: URL, timings: [WordTiming])? {
        guard isSurahDownloaded(reciterId: reciterId, surahNumber: surahNumber) else { return nil }

        let (audioURL, timingsURL) = getFilePaths(reciterId: reciterId, surahNumber: surahNumber)
        guard FileManager.default.fileExists(atPath: audioURL.path) else { return nil }

        var timings: [WordTiming] = []
        if FileManager.default.fileExists(atPath: timingsURL.path),
           let data = try? Data(contentsOf: timingsURL),
           let decoded = try? JSONDecoder().decode([WordTiming].self, from: data) {
            timings = decoded
        }

        return (audioURL: audioURL, timings: timings)
    }

    /// Total storage size used by all downloads in bytes
    public var totalStorageSize: Int64 {
        downloads.reduce(0) { $0 + $1.fileSize }
    }

    /// Formatted total storage size string (e.g. "124.5 MB")
    public var formattedTotalStorageSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalStorageSize)
    }

    /// Downloads grouped by reciter
    public var downloadsByReciter: [Int: [DownloadedSurah]] {
        Dictionary(grouping: downloads, by: { $0.reciterId })
    }

    // MARK: - Download Action API

    /// Start downloading audio and word timings for a surah by a specific reciter
    public func downloadSurah(reciter: Reciter, surahNumber: Int, surahName: String) {
        let key = "\(reciter.id)_\(surahNumber)"
        guard activeDownloads[key] == nil else { return }

        activeDownloads[key] = 0.05
        downloadErrors.removeValue(forKey: key)

        // 1. Fetch chapter audio DTO to get CDN URL and timings
        let repo = ListeningRepositoryImpl(networkService: networkService)
        let audioPub = repo.fetchAudioURL(reciterId: reciter.id, chapterNumber: surahNumber)
        let timingsPub = repo.fetchWordTimings(reciterId: reciter.id, chapterNumber: surahNumber)

        Publishers.Zip(audioPub, timingsPub)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.activeDownloads.removeValue(forKey: key)
                        self?.downloadErrors[key] = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] (remoteAudioURL, timings) in
                    guard let self else { return }
                    self.performFileDownload(
                        key: key,
                        reciter: reciter,
                        surahNumber: surahNumber,
                        surahName: surahName,
                        remoteAudioURL: remoteAudioURL,
                        timings: timings
                    )
                }
            )
            .store(in: &cancellables)
    }

    private var activeSessions: [String: (URLSession, NSObject)] = [:]

    private func performFileDownload(
        key: String,
        reciter: Reciter,
        surahNumber: Int,
        surahName: String,
        remoteAudioURL: URL,
        timings: [WordTiming]
    ) {
        activeDownloads[key] = 0.01

        let handler = DownloadDelegateHandler(
            onProgress: { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.activeDownloads[key] = progress
                }
            },
            onCompletion: { [weak self] tempLocation, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    defer { self.activeSessions.removeValue(forKey: key) }

                    guard let tempLocation = tempLocation, error == nil else {
                        self.activeDownloads.removeValue(forKey: key)
                        self.downloadErrors[key] = error?.localizedDescription ?? "Download failed"
                        return
                    }

                    let (audioURL, timingsURL) = self.getFilePaths(reciterId: reciter.id, surahNumber: surahNumber)
                    let reciterFolder = audioURL.deletingLastPathComponent()
                    try? FileManager.default.createDirectory(at: reciterFolder, withIntermediateDirectories: true)

                    try? FileManager.default.removeItem(at: audioURL)
                    do {
                        if FileManager.default.fileExists(atPath: tempLocation.path) {
                            try FileManager.default.copyItem(at: tempLocation, to: audioURL)
                            try? FileManager.default.removeItem(at: tempLocation)
                        } else {
                            throw NSError(domain: "AudioDownloadManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Temp audio file not found"])
                        }
                    } catch {
                        self.activeDownloads.removeValue(forKey: key)
                        self.downloadErrors[key] = "Failed to save audio file: \(error.localizedDescription)"
                        return
                    }

                    if let timingsData = try? JSONEncoder().encode(timings) {
                        try? timingsData.write(to: timingsURL)
                    }

                    let attributes = try? FileManager.default.attributesOfItem(atPath: audioURL.path)
                    let fileSize = (attributes?[.size] as? Int64) ?? 0

                    let item = DownloadedSurah(
                        reciterId: reciter.id,
                        reciterName: reciter.name,
                        reciterArabicName: reciter.arabicName,
                        surahNumber: surahNumber,
                        surahName: surahName,
                        fileSize: fileSize,
                        audioFileName: audioURL.lastPathComponent,
                        timingsFileName: timingsURL.lastPathComponent,
                        downloadedAt: Date()
                    )

                    self.downloads.removeAll(where: { $0.id == key })
                    self.downloads.append(item)
                    self.saveRegistry()

                    self.activeDownloads[key] = 1.0
                    try? await Task.sleep(for: .milliseconds(300))
                    self.activeDownloads.removeValue(forKey: key)
                }
            }
        )

        let session = URLSession(configuration: .default, delegate: handler, delegateQueue: nil)
        let task = session.downloadTask(with: remoteAudioURL)
        activeSessions[key] = (session, handler)
        task.resume()
    }

    // MARK: - Deletion API

    /// Delete a single surah download
    public func deleteDownload(reciterId: Int, surahNumber: Int) {
        let key = "\(reciterId)_\(surahNumber)"
        let (audioURL, timingsURL) = getFilePaths(reciterId: reciterId, surahNumber: surahNumber)

        try? FileManager.default.removeItem(at: audioURL)
        try? FileManager.default.removeItem(at: timingsURL)

        downloads.removeAll(where: { $0.id == key })
        saveRegistry()
    }

    /// Selective bulk delete by item IDs (Set of "reciterId_surahNumber")
    public func deleteDownloads(ids: Set<String>) {
        for id in ids {
            let parts = id.split(separator: "_").compactMap { Int($0) }
            if parts.count == 2 {
                deleteDownload(reciterId: parts[0], surahNumber: parts[1])
            }
        }
    }

    /// Delete all downloaded surahs for a specific reciter
    public func deleteReciterDownloads(reciterId: Int) {
        let reciterItems = downloads.filter { $0.reciterId == reciterId }
        for item in reciterItems {
            deleteDownload(reciterId: item.reciterId, surahNumber: item.surahNumber)
        }
        let reciterFolder = baseFolderURL.appendingPathComponent("\(reciterId)", isDirectory: true)
        try? FileManager.default.removeItem(at: reciterFolder)
    }

    /// Delete all offline recordings/surahs
    public func deleteAllDownloads() {
        for item in downloads {
            let (audioURL, timingsURL) = getFilePaths(reciterId: item.reciterId, surahNumber: item.surahNumber)
            try? FileManager.default.removeItem(at: audioURL)
            try? FileManager.default.removeItem(at: timingsURL)
        }
        try? FileManager.default.removeItem(at: baseFolderURL)
        downloads.removeAll()
        saveRegistry()
    }

    // MARK: - Private Helpers

    private func getFilePaths(reciterId: Int, surahNumber: Int) -> (audioURL: URL, timingsURL: URL) {
        let reciterFolder = baseFolderURL.appendingPathComponent("\(reciterId)", isDirectory: true)
        let audioURL = reciterFolder.appendingPathComponent("surah_\(surahNumber).mp3")
        let timingsURL = reciterFolder.appendingPathComponent("surah_\(surahNumber)_timings.json")
        return (audioURL: audioURL, timingsURL: timingsURL)
    }

    private func saveRegistry() {
        if let data = try? JSONEncoder().encode(downloads) {
            UserDefaults.standard.set(data, forKey: userStorageKey)
        }
    }

    private func loadPersistedRegistry() {
        guard let data = UserDefaults.standard.data(forKey: userStorageKey),
              let list = try? JSONDecoder().decode([DownloadedSurah].self, from: data) else {
            self.downloads = []
            return
        }
        // Verify files exist on disk
        self.downloads = list.filter { item in
            let (audioURL, _) = getFilePaths(reciterId: item.reciterId, surahNumber: item.surahNumber)
            return FileManager.default.fileExists(atPath: audioURL.path)
        }
    }
}

// MARK: - Delegate Handler for URLSession Download Progress

private final class DownloadDelegateHandler: NSObject, URLSessionDownloadDelegate {
    typealias ProgressCallback = (Double) -> Void
    typealias CompletionCallback = (URL?, Error?) -> Void

    let onProgress: ProgressCallback
    let onCompletion: CompletionCallback

    init(onProgress: @escaping ProgressCallback, onCompletion: @escaping CompletionCallback) {
        self.onProgress = onProgress
        self.onCompletion = onCompletion
        super.init()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let expected = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : 12_000_000
        let fraction = min(0.98, max(0.01, Double(totalBytesWritten) / Double(expected)))
        onProgress(fraction)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let stagingURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
        do {
            try? FileManager.default.removeItem(at: stagingURL)
            try FileManager.default.copyItem(at: location, to: stagingURL)
            onCompletion(stagingURL, nil)
        } catch {
            onCompletion(nil, error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            onCompletion(nil, error)
        }
    }
}
