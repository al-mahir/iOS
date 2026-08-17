//
//  ListeningViewModel.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

/// Central ViewModel for the Listening Module.
/// Coordinates fetching reciters, loading audio sessions, and driving the AudioSyncManager.
@MainActor
public final class ListeningViewModel: ObservableObject {

    // MARK: - Published State

    @Published public private(set) var reciters: [Reciter]          = []
    @Published public var selectedReciter: Reciter?                  = nil
    @Published public private(set) var isListeningModeActive        = false
    @Published public private(set) var isLoading                    = false
    @Published public private(set) var errorMessage: String?        = nil
    @Published public private(set) var currentChapterNumber: Int    = 1
    @Published public private(set) var currentChapterName: String   = ""

    public var currentChapterStartPage: Int {
        SurahData.pageStart(for: currentChapterNumber)
    }

    // Forwarded from AudioSyncManager
    @Published public private(set) var currentWordKey: String?
    @Published public private(set) var playbackState: PlaybackState = .idle
    @Published public private(set) var progress: Double             = 0
    @Published public private(set) var currentTimeDisplay: String   = "0:00"
    @Published public private(set) var durationDisplay: String      = "0:00"
    @Published public private(set) var isPlayingOffline: Bool       = false

    // Listening preferences
    @Published public private(set) var isWordHighlightEnabled: Bool = true
    @Published public private(set) var isRepeatEnabled: Bool        = false

    // Page navigation — incremented on every explicit seek so MushafView can onChange
    @Published public private(set) var navigationRequestId: Int     = 0
    private var navigationSurah: Int = 0
    private var navigationAyah: Int  = 0

    // MARK: - Dependencies

    public let audioManager: AudioSyncManager
    public let downloadManager: AudioDownloadManager
    private let fetchReciters: FetchRecitersUseCase
    private let fetchWordTimings: FetchWordTimingsUseCase
    private let fetchAudioURL: FetchAudioURLUseCase

    private var startAyahOnLoad: Int = 1   // ayah to seek to after audio loads
    private var cancellables = Set<AnyCancellable>()
    private var sessionCancellables = Set<AnyCancellable>()

    // MARK: - Init

    nonisolated public init(
        audioManager: AudioSyncManager,
        downloadManager: AudioDownloadManager = .shared,
        fetchReciters: FetchRecitersUseCase,
        fetchWordTimings: FetchWordTimingsUseCase,
        fetchAudioURL: FetchAudioURLUseCase
    ) {
        self.audioManager     = audioManager
        self.downloadManager  = downloadManager
        self.fetchReciters    = fetchReciters
        self.fetchWordTimings = fetchWordTimings
        self.fetchAudioURL    = fetchAudioURL

        // Defer @MainActor work — same pattern as MushafViewModel.nonisolated init
        Task { @MainActor [self] in
            self.bindAudioManager()
            self.loadReciters()
        }
    }

    // MARK: - Public API

    /// Activate listening mode for a specific surah, starting from `startAyah`.
    /// Default `startAyah = 1` plays from the chapter beginning.
    public func activateListeningMode(surahNumber: Int, surahName: String = "", startAyah: Int = 1) {
        let finalSurahName = surahName.isEmpty ? SurahData.englishName(for: surahNumber) : surahName
        let isSameSurahSession = isListeningModeActive && currentChapterNumber == surahNumber && playbackState != .idle

        isListeningModeActive  = true
        currentChapterNumber   = surahNumber
        currentChapterName     = finalSurahName
        startAyahOnLoad        = startAyah

        if selectedReciter != nil && !isSameSurahSession {
            loadAudioSession()
        } else if isSameSurahSession && startAyah > 1 {
            seekToAyah(surah: surahNumber, ayah: startAyah)
        }

        navigationSurah        = surahNumber
        navigationAyah         = startAyah
        navigationRequestId   += 1
    }

    /// Deactivate listening mode and stop audio.
    public func deactivateListeningMode() {
        isListeningModeActive = false
        audioManager.stop()
    }

    /// Select a new reciter and reload the session if active.
    public func selectReciter(_ reciter: Reciter) {
        selectedReciter = reciter
        if isListeningModeActive {
            loadAudioSession()
        }
    }

    /// Transport controls — delegate to AudioSyncManager
    public func play()            { audioManager.play() }
    public func pause()           { audioManager.pause() }
    public func togglePlayPause() { audioManager.togglePlayPause() }

    public func seek(to fraction: Double) {
        audioManager.seek(to: fraction)
        emitNavigationAfterSeek()
    }

    public func skip(seconds: Double) {
        audioManager.skip(seconds: seconds)
        emitNavigationAfterSeek()
    }

    public func previousAyah() {
        audioManager.previousAyah()
        emitNavigationAfterSeek()
    }

    public func nextAyah() {
        audioManager.nextAyah()
        emitNavigationAfterSeek()
    }

    /// Navigate to the previous surah (1..114)
    public func previousSurah() {
        guard currentChapterNumber > 1 else {
            audioManager.seekToMs(0)
            return
        }
        let prev = currentChapterNumber - 1
        activateListeningMode(surahNumber: prev, surahName: SurahData.englishName(for: prev), startAyah: 1)
    }

    /// Navigate to the proceeding (next) surah (1..114)
    public func nextSurah() {
        guard currentChapterNumber < 114 else { return }
        let next = currentChapterNumber + 1
        activateListeningMode(surahNumber: next, surahName: SurahData.englishName(for: next), startAyah: 1)
    }

    /// Seek directly to a specific ayah (page swipe — does NOT trigger page navigation).
    public func seekToAyah(surah: Int, ayah: Int) {
        audioManager.seekToAyah(surah: surah, ayah: ayah)
    }

    /// Returns the surah+ayah last emitted for page navigation.
    public func navigationTarget() -> (surah: Int, ayah: Int) {
        (navigationSurah, navigationAyah)
    }

    /// Toggle word-by-word highlight on/off
    public func toggleWordHighlight() {
        isWordHighlightEnabled.toggle()
    }

    /// Toggle chapter repeat on/off
    public func toggleRepeat() {
        isRepeatEnabled.toggle()
    }

    // MARK: - Private — Page Navigation

    /// Called after every explicit user seek. Waits 150ms for the time observer to settle
    /// on the new currentWordKey, then signals MushafView to navigate to that page.
    private func emitNavigationAfterSeek() {
        Task { @MainActor [weak self] in
            // Small delay lets AVPlayer's periodic observer publish the new word key
            try? await Task.sleep(for: .milliseconds(150))
            guard let self, let key = self.currentWordKey else { return }
            let parts = key.split(separator: ":").compactMap { Int($0) }
            guard parts.count >= 2 else { return }
            self.navigationSurah = parts[0]
            self.navigationAyah  = parts[1]
            self.navigationRequestId += 1
        }
    }

    // MARK: - Private — Data Loading

    private func loadReciters() {
        fetchReciters.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Could not load reciters: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] reciters in
                    guard let self else { return }
                    self.reciters = reciters
                    // Default to first reciter if none selected
                    if self.selectedReciter == nil {
                        self.selectedReciter = reciters.first
                        if self.isListeningModeActive {
                            self.loadAudioSession()
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }

    private func loadAudioSession() {
        guard let reciter = selectedReciter else { return }

        sessionCancellables.removeAll()
        isLoading     = true
        errorMessage  = nil

        let chapter   = currentChapterNumber
        let reciterId = reciter.id

        // Check if offline local file & timings are available
        if let (localAudioURL, localTimings) = downloadManager.getLocalAudioAndTimings(reciterId: reciterId, surahNumber: chapter) {
            isLoading = false
            isPlayingOffline = true

            let targetAyah = self.startAyahOnLoad
            let startMs: Int
            if targetAyah > 1,
               let firstWord = localTimings.first(where: { $0.ayah == targetAyah }) {
                startMs = firstWord.startMs
            } else {
                startMs = 0
            }

            self.audioManager.load(url: localAudioURL, wordTimings: localTimings, startMs: startMs)
            self.audioManager.setNowPlayingMetadata(
                title: self.currentChapterName,
                artist: reciter.localizedName,
                chapterName: self.currentChapterName
            )
            return
        }

        // Online streaming fallback
        isPlayingOffline = false

        // Fetch both audio URL and word timings concurrently
        let audioURLPub: AnyPublisher<URL, NetworkError>          = fetchAudioURL.execute(reciterId: reciterId, chapterNumber: chapter)
        let timingsPub: AnyPublisher<[WordTiming], NetworkError>  = fetchWordTimings.execute(reciterId: reciterId, chapterNumber: chapter)

        Publishers.Zip(audioURLPub, timingsPub)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                        self.playbackState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] (url, timings) in
                    guard let self else { return }
                    self.isLoading = false

                    // Calculate startMs: find first word of startAyahOnLoad in the timings.
                    // If ayah 1 or not found, defaults to 0 (chapter beginning).
                    let targetAyah = self.startAyahOnLoad
                    let startMs: Int
                    if targetAyah > 1,
                       let firstWord = timings.first(where: { $0.ayah == targetAyah }) {
                        startMs = firstWord.startMs
                    } else {
                        startMs = 0
                    }

                    self.audioManager.load(url: url, wordTimings: timings, startMs: startMs)
                    self.audioManager.setNowPlayingMetadata(
                        title: self.currentChapterName,
                        artist: reciter.localizedName,
                        chapterName: self.currentChapterName
                    )
                }
            )
            .store(in: &sessionCancellables)
    }

    // MARK: - Binding AudioSyncManager → ViewModel

    private func bindAudioManager() {
        audioManager.onNextSurah = { [weak self] in self?.nextSurah() }
        audioManager.onPreviousSurah = { [weak self] in self?.previousSurah() }

        audioManager.$currentWordKey
            .assign(to: &$currentWordKey)

        audioManager.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.playbackState = state
                // Finished handling: repeat if enabled, or auto-advance to next surah
                if state == .finished {
                    if self.isRepeatEnabled {
                        self.audioManager.seekToMs(0)
                        self.audioManager.play()
                    } else if self.currentChapterNumber < 114 {
                        self.nextSurah()
                    }
                }
            }
            .store(in: &cancellables)

        audioManager.$progress
            .assign(to: &$progress)

        audioManager.$currentTimeMs
            .map { [weak self] _ in self?.audioManager.currentTimeDisplay ?? "0:00" }
            .assign(to: &$currentTimeDisplay)

        audioManager.$durationMs
            .map { [weak self] _ in self?.audioManager.durationDisplay ?? "0:00" }
            .assign(to: &$durationDisplay)
    }
}
