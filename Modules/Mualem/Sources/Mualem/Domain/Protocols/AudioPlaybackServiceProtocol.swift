//
//  AudioPlaybackServiceProtocol.swift
//  Mualem
//

import Foundation

import Combine

@MainActor
public protocol AudioPlaybackServiceProtocol {
    /// Loads and prepares audio dynamically for the given Surah and Ayah range using the specified Qari ID.
    /// The adapter must stop playback when the audio reaches beyond `endAyah`.
    func loadAudio(surah: Int, startAyah: Int, endAyah: Int, qariId: String)
    
    /// Play the loaded audio.
    func play()
    
    /// Pause the loaded audio.
    func pause()
    
    /// Stop playback and release resources.
    func stop()
    
    /// A publisher or callback for playback completion.
    var onPlaybackFinished: (() -> Void)? { get set }
    
    /// Publishes the currently active word key based on the loaded timings.
    var activeWordKeyPublisher: AnyPublisher<String?, Never> { get }
}
