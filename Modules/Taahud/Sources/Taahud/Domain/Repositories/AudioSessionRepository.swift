//
//  AudioSessionRepository.swift
//  Reading
//
//  Domain layer contract for microphone capture. The implementation owns
//  AVAudioEngine/AVAudioSession/AVAudioConverter entirely; nothing above this
//  boundary should import AVFoundation.
//

import Foundation

/// Contract for capturing microphone audio and converting it to the exact
/// wire format the recitation engine expects: 16000 Hz, mono, Int16 PCM,
/// little-endian, delivered in ~100ms (3200 byte) frames.
public protocol AudioSessionRepository {

    /// Configures the audio session (category `.playAndRecord`, mode
    /// `.measurement` — required to disable system AGC/noise cancellation,
    /// which otherwise distorts madd vowels) and starts the audio engine.
    /// Each element of the returned stream is one ready-to-send PCM16 frame.
    func startCapture() async throws -> AsyncThrowingStream<Data, Error>

    /// Stops the audio engine and tears down the tap. Safe to call even if
    /// capture was never started.
    func stopCapture() async

    /// Whether the app currently holds microphone permission.
    func hasMicrophonePermission() async -> Bool

    /// Prompts the system permission dialog if not already determined.
    func requestMicrophonePermission() async -> Bool
}
