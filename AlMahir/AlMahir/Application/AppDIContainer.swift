//
//  AppDIContainer.swift
//  AlMahir
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Swinject
import Profile 
import Mualem
import Listening
import Foundation
import Combine

final class AppDIContainer {
    static let shared = AppDIContainer()
    
    let container: Container
    private let assembler: Assembler
    
    private init() {
        container = Container()
        
        assembler = Assembler([
            ProfileAssembly(),
            MuallimAssembly(),
            ListeningAssembly()
        ], container: container)
        
        // Register the Audio Adapter for Mualem
        container.register(AudioPlaybackServiceProtocol.self) { r in
            MainActor.assumeIsolated {
                let audioSyncManager = r.resolve(AudioSyncManager.self)!
                let fetchAudioURL = r.resolve(FetchAudioURLUseCase.self)!
                let fetchWordTimings = r.resolve(FetchWordTimingsUseCase.self)!
                return AudioPlaybackServiceAdapter(
                    manager: audioSyncManager,
                    fetchAudioURL: fetchAudioURL,
                    fetchWordTimings: fetchWordTimings
                )
            }
        }.inObjectScope(.container)
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(T.self)
    }
}

// MARK: - AudioPlaybackServiceAdapter
@MainActor
class AudioPlaybackServiceAdapter: AudioPlaybackServiceProtocol {
    private let manager: AudioSyncManager
    private let fetchAudioURL: FetchAudioURLUseCase
    private let fetchWordTimings: FetchWordTimingsUseCase
    
    var onPlaybackFinished: (() -> Void)?
    
    var activeWordKeyPublisher: AnyPublisher<String?, Never> {
        manager.$currentWordKey.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var sessionCancellables = Set<AnyCancellable>()
    
    /// Whether we already triggered the end-boundary stop for this session.
    private var didTriggerEndBoundary = false
    
    init(manager: AudioSyncManager, fetchAudioURL: FetchAudioURLUseCase, fetchWordTimings: FetchWordTimingsUseCase) {
        self.manager = manager
        self.fetchAudioURL = fetchAudioURL
        self.fetchWordTimings = fetchWordTimings
        
        // Listen for natural playback completion (end of file) and trigger the callback
        manager.$playbackState
            .sink { [weak self] state in
                guard let self, !self.didTriggerEndBoundary else { return }
                switch state {
                case .finished:
                    self.onPlaybackFinished?()
                case .error(let msg):
                    print("AudioSyncManager Error: \(msg)")
                    self.onPlaybackFinished?()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func loadAudio(surah: Int, startAyah: Int, endAyah: Int, qariId: String) {
        // qariId is passed as String, but Listening module expects Int
        let reciterId = Int(qariId) ?? 1
        
        sessionCancellables.removeAll()
        didTriggerEndBoundary = false
        
        let audioURLPub = fetchAudioURL.execute(reciterId: reciterId, chapterNumber: surah)
        let timingsPub = fetchWordTimings.execute(reciterId: reciterId, chapterNumber: surah)
        
        Publishers.Zip(audioURLPub, timingsPub)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Failed to fetch audio session for Mualem: \(error)")
                        self?.onPlaybackFinished?()
                    }
                },
                receiveValue: { [weak self] (url, timings) in
                    guard let self else { return }
                    
                    // Filter timings to only include words within the requested ayah range
                    let filteredTimings = timings.filter { $0.ayah >= startAyah && $0.ayah <= endAyah }
                    
                    let startMs: Int
                    if let firstWord = filteredTimings.first {
                        startMs = firstWord.startMs
                    } else {
                        startMs = 0
                    }
                    
                    // Load with filtered timings so only the selected ayah range gets word-key highlighting
                    self.manager.load(url: url, wordTimings: filteredTimings, startMs: startMs)
                    
                    // Use AVPlayer's precise boundary time observer to stop exactly at the end of endAyah.
                    // This fires at the exact audio frame, unlike Combine's @Published which can lag.
                    if let lastWord = filteredTimings.last {
                        self.manager.addBoundaryObserver(atMs: lastWord.endMs) { [weak self] in
                            guard let self, !self.didTriggerEndBoundary else { return }
                            self.didTriggerEndBoundary = true
                            self.manager.pause()
                            self.onPlaybackFinished?()
                        }
                    }
                }
            )
            .store(in: &sessionCancellables)
    }
    
    func play() {
        manager.play()
    }
    
    func pause() {
        manager.pause()
    }
    
    func stop() {
        manager.stop()
    }
}
