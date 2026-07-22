//
//  AudioSyncManager.swift
//  Listening
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

/// The core audio engine for the Listening Module.
/// Wraps AVPlayer with:
///  - CDN streaming (no local storage)
///  - 50ms periodic time observer → publishes `currentWordKey`
///  - Now Playing info for Control Center / Lock Screen
///  - Background audio session configuration
@MainActor
public final class AudioSyncManager: ObservableObject {

    // MARK: - Published State

    @Published public private(set) var playbackState: PlaybackState = .idle
    @Published public private(set) var currentWordKey: String?      = nil
    @Published public private(set) var progress: Double             = 0   // 0.0 – 1.0
    @Published public private(set) var currentTimeMs: Int           = 0
    @Published public private(set) var durationMs: Int              = 0
    @Published public private(set) var speed: PlaybackSpeed         = .normal

    // MARK: - Private

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var wordTimings: [WordTiming] = []
    private var startMsOnLoad: Int = 0   // seek target after readyToPlay
    private var cancellables = Set<AnyCancellable>()
    private var statusObserver: AnyCancellable?
    private var didFinishObserver: NSObjectProtocol?

    // MARK: - Init / Deinit

    nonisolated init() {
        // Defer @MainActor work — same pattern as MushafViewModel
        Task { @MainActor [self] in
            self.configureAudioSession()
            self.setupRemoteCommandCenter()
        }
    }

    nonisolated deinit {
        // Capture values nonisolated — AVPlayer and observers clean up via ARC.
        // ViewModel calls stop() explicitly before release, so tearDown already ran.
    }

    // MARK: - Public API

    /// Load and begin streaming from `url`, seeking to `startMs` before playback begins.
    /// Pass `startMs = 0` to start from the chapter beginning.
    public func load(url: URL, wordTimings: [WordTiming], startMs: Int = 0) {
        tearDown()
        self.wordTimings    = wordTimings
        self.startMsOnLoad  = startMs
        currentWordKey  = nil
        progress        = 0
        currentTimeMs   = 0

        playbackState = .loading

        let item   = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player = player

        observeStatus(for: item)
        observeFinish(for: player)
        attachPeriodicObserver(to: player)

        // Observe duration
        item.publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                guard let self, duration.isNumeric else { return }
                self.durationMs = Int(duration.seconds * 1000)
                self.updateNowPlaying()
            }
            .store(in: &cancellables)
    }

    public func play() {
        guard let player else { return }
        player.play()
        player.rate = Float(speed.rawValue)
        playbackState = .playing
        updateNowPlaying()
    }

    public func pause() {
        player?.pause()
        playbackState = .paused
        updateNowPlaying()
    }

    public func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .paused, .idle, .finished, .error:
            play()
        case .loading:
            break
        }
    }

    public func seek(to fraction: Double) {
        guard let player, durationMs > 0 else { return }
        let targetMs  = Int(fraction * Double(durationMs))
        let targetSec = Double(targetMs) / 1000.0
        let time      = CMTime(seconds: targetSec, preferredTimescale: 1000)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTimeMs   = targetMs
        progress        = fraction
        currentWordKey  = wordKey(forMs: targetMs)
    }

    public func seekToMs(_ ms: Int) {
        guard durationMs > 0 else { return }
        seek(to: Double(ms) / Double(durationMs))
    }

    /// Skip forward / backward by a fixed number of seconds
    public func skip(seconds: Double) {
        let newMs = currentTimeMs + Int(seconds * 1000)
        let clampedMs = max(0, min(newMs, durationMs))
        seekToMs(clampedMs)
    }

    /// Seek to the start of the ayah (first word with matching surah:ayah)
    public func seekToAyah(surah: Int, ayah: Int) {
        guard let firstWord = wordTimings.first(where: { $0.surah == surah && $0.ayah == ayah }) else { return }
        seekToMs(firstWord.startMs)
    }

    /// Navigate to previous ayah
    public func previousAyah() {
        guard let current = currentTiming() else { seekToMs(0); return }
        let prevAyah = current.ayah > 1 ? current.ayah - 1 : current.ayah
        seekToAyah(surah: current.surah, ayah: prevAyah)
    }

    /// Navigate to next ayah
    public func nextAyah() {
        guard let current = currentTiming() else { return }
        let nextAyah = current.ayah + 1
        if let _ = wordTimings.first(where: { $0.surah == current.surah && $0.ayah == nextAyah }) {
            seekToAyah(surah: current.surah, ayah: nextAyah)
        }
    }

    public func setSpeed(_ newSpeed: PlaybackSpeed) {
        speed = newSpeed
        if playbackState == .playing {
            player?.rate = Float(newSpeed.rawValue)
        }
    }

    public func stop() {
        tearDown()
        playbackState  = .idle
        currentWordKey = nil
        progress       = 0
        currentTimeMs  = 0
    }

    // MARK: - Time Display Helpers

    public var currentTimeDisplay: String { formatTime(ms: currentTimeMs) }
    public var durationDisplay: String    { formatTime(ms: durationMs) }

    private func formatTime(ms: Int) -> String {
        let totalSeconds = ms / 1000
        let minutes      = totalSeconds / 60
        let seconds      = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Private — Observers

    private func attachPeriodicObserver(to player: AVPlayer) {
        // Fire every 50 ms for smooth word-by-word tracking
        let interval = CMTime(value: 1, timescale: 20) // 50ms
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self, time.isNumeric else { return }
            let ms = Int(time.seconds * 1000)
            self.currentTimeMs  = ms
            self.progress       = self.durationMs > 0 ? Double(ms) / Double(self.durationMs) : 0
            let key             = self.wordKey(forMs: ms)
            if key != self.currentWordKey {
                self.currentWordKey = key
            }
            self.updateNowPlayingTime()
        }
    }

    private func observeStatus(for item: AVPlayerItem) {
        statusObserver = item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    // Seek to start position (e.g. mid-surah page) before playing
                    if self.startMsOnLoad > 0 {
                        self.seekToMs(self.startMsOnLoad)
                        self.startMsOnLoad = 0
                    }
                    self.play()
                case .failed:
                    let msg = item.error?.localizedDescription ?? "Unknown playback error"
                    self.playbackState = .error(msg)
                default:
                    break
                }
            }
    }

    private func observeFinish(for player: AVPlayer) {
        didFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.playbackState = .finished
            self?.currentWordKey = nil
        }
    }

    // MARK: - Binary Search — Word Lookup

    /// Finds the WordTiming active at a given millisecond offset using binary search.
    private func wordKey(forMs ms: Int) -> String? {
        guard !wordTimings.isEmpty else { return nil }
        var lo = 0
        var hi = wordTimings.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            let timing = wordTimings[mid]
            if timing.contains(ms: ms) {
                return timing.wordKey
            } else if ms < timing.startMs {
                hi = mid - 1
            } else {
                lo = mid + 1
            }
        }
        return nil
    }

    private func currentTiming() -> WordTiming? {
        wordTimings.first { $0.contains(ms: currentTimeMs) }
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioSyncManager] AVAudioSession setup failed: \(error)")
        }
    }

    // MARK: - Now Playing / Remote Control

    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget  { [weak self] _ in self?.play();  return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.pause(); return .success }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause(); return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextAyah(); return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousAyah(); return .success
        }
        center.changePlaybackPositionCommand.isEnabled = true
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self,
                  let posEvent = event as? MPChangePlaybackPositionCommandEvent
            else { return .commandFailed }
            let ms = Int(posEvent.positionTime * 1000)
            self.seekToMs(ms)
            return .success
        }
    }

    private func updateNowPlaying() {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate]  = playbackState == .playing ? speed.rawValue : 0.0
        info[MPMediaItemPropertyPlaybackDuration]   = Double(durationMs) / 1000.0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(currentTimeMs) / 1000.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingTime() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(currentTimeMs) / 1000.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// Populate Now Playing metadata (call after session is loaded)
    public func setNowPlayingMetadata(title: String, artist: String, chapterName: String) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyTitle]         = title
        info[MPMediaItemPropertyArtist]        = artist
        info[MPMediaItemPropertyAlbumTitle]    = chapterName
        info[MPMediaItemPropertyPlaybackDuration] = Double(durationMs) / 1000.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Teardown

    private func tearDown() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        if let obs = didFinishObserver {
            NotificationCenter.default.removeObserver(obs)
            didFinishObserver = nil
        }
        statusObserver?.cancel()
        statusObserver = nil
        cancellables.removeAll()
        player?.pause()
        player = nil
    }
}
