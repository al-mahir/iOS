//
//  AudioRecorderService.swift
//  Taahud
//
//  Data layer.

import Foundation
import AVFoundation

enum AudioRecorderError: LocalizedError {
    case permissionDenied
    case converterCreationFailed
    case engineStartFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return String(
                localized: "Microphone access was not granted.",
                comment: "Error message when microphone permission is denied"
            )
            
        case .converterCreationFailed:
            return String(
                localized: "Could not create an audio converter to 16kHz mono PCM16.",
                comment: "Error message when audio converter initialization fails"
            )
            
        case .engineStartFailed(let underlying):
            return String(
                localized: "Could not start the audio engine: \(underlying.localizedDescription)",
                comment: "Error message when audio engine fails to start"
            )
        }
    }
}

final class AudioRecorderService: AudioSessionRepository {

    // Fixed by the server contract (API.md §2.3 / SETUP.md TAJWID_SAMPLE_RATE — do not change).
    private static let targetSampleRate: Double = 16000
    private static let targetChannelCount: AVAudioChannelCount = 1
    private static let frameDurationSeconds: Double = 0.1 // ~100ms per frame
    private static let bytesPerFrame = Int(targetSampleRate * frameDurationSeconds) * 2 // Int16 = 2 bytes

    private let audioEngine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private var targetFormat: AVAudioFormat?
    private var pendingBytes = Data()
    private var capturedFrameCount = 0

    func hasMicrophonePermission() async -> Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }

    func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func startCapture() async throws -> AsyncThrowingStream<Data, Error> {
        var granted = await hasMicrophonePermission()
        if !granted {
            granted = await requestMicrophonePermission()
        }
        guard granted else {
            throw AudioRecorderError.permissionDenied
        }

        // Mandatory per API.md §2.3: .measurement disables system AGC/noise
        // cancellation, which otherwise distorts madd vowel length — exactly
        // the thing the tajweed grading depends on being accurate.
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let hardwareFormat = inputNode.outputFormat(forBus: 0)

        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: Self.targetSampleRate,
            channels: Self.targetChannelCount,
            interleaved: true
        ) else {
            throw AudioRecorderError.converterCreationFailed
        }
        self.targetFormat = targetFormat

        guard let converter = AVAudioConverter(from: hardwareFormat, to: targetFormat) else {
            throw AudioRecorderError.converterCreationFailed
        }
        self.converter = converter

        pendingBytes.removeAll(keepingCapacity: true)
        capturedFrameCount = 0

        return AsyncThrowingStream { continuation in
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: hardwareFormat) { [weak self] buffer, _ in
                guard let self else { return }
                do {
                    for frame in try self.convertAndChunk(buffer: buffer, converter: converter, targetFormat: targetFormat) {
                        continuation.yield(frame)
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            audioEngine.prepare()
            do {
                try audioEngine.start()
                print("🎙️ [Taahud/Audio] engine started — converting \(hardwareFormat.sampleRate)Hz → 16kHz mono PCM16")
            } catch {
                continuation.finish(throwing: AudioRecorderError.engineStartFailed(underlying: error))
                return
            }

            continuation.onTermination = { [weak self] _ in
                self?.teardownEngine()
            }
        }
    }

    func stopCapture() async {
        teardownEngine()
    }

    // MARK: - Conversion

    private func convertAndChunk(buffer: AVAudioPCMBuffer, converter: AVAudioConverter, targetFormat: AVAudioFormat) throws -> [Data] {
        let outputCapacity = AVAudioFrameCount(
            (Double(buffer.frameLength) * Self.targetSampleRate / buffer.format.sampleRate).rounded(.up) + 16
        )
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outputCapacity) else {
            return []
        }

        var error: NSError?
        var suppliedInput = false
        converter.convert(to: outputBuffer, error: &error) { _, inputStatus in
            if suppliedInput {
                inputStatus.pointee = .noDataNow
                return nil
            }
            suppliedInput = true
            inputStatus.pointee = .haveData
            return buffer
        }
        if let error {
            throw error
        }

        guard let channelData = outputBuffer.int16ChannelData else { return [] }
        let sampleCount = Int(outputBuffer.frameLength)
        let byteCount = sampleCount * 2 // Int16
        guard byteCount > 0 else { return [] }

        let newBytes = Data(bytes: channelData[0], count: byteCount)
        pendingBytes.append(newBytes)

        var frames: [Data] = []
        while pendingBytes.count >= Self.bytesPerFrame {
            frames.append(pendingBytes.prefix(Self.bytesPerFrame))
            pendingBytes.removeFirst(Self.bytesPerFrame)
        }

        capturedFrameCount += frames.count
        if !frames.isEmpty, capturedFrameCount % 10 < frames.count {
            let samples = frames.last!.withUnsafeBytes { $0.bindMemory(to: Int16.self) }
            let peak = samples.map { abs(Int32($0)) }.max() ?? 0
            let peakPercent = Double(peak) / Double(Int16.max) * 100
            print("🎚️ [Taahud/Audio] frame #\(capturedFrameCount) peak amplitude: \(peak)/\(Int16.max) (\(String(format: "%.1f", peakPercent))%)")
        }

        return frames
    }

    private func teardownEngine() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        converter = nil
        pendingBytes.removeAll()
        print("🎙️ [Taahud/Audio] engine stopped")
    }
}
