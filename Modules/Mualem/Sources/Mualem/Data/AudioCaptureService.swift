// AudioCaptureService.swift
// Mualem

import Foundation
import AVFoundation

enum LocalSpeechActivity: Sendable {
    case speaking
    case silent
}

final class AudioCaptureService: @unchecked Sendable {
    private var audioEngine: AVAudioEngine?
    private var continuation: AsyncStream<Data>.Continuation?
    private(set) var isCapturing = false
    private let targetFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!
    
    var onLocalSpeechActivityChanged: ((LocalSpeechActivity) -> Void)?
    private var lastActivity: LocalSpeechActivity = .silent
    private let activityThreshold: Float = 0.015
    
    func startCapture() -> AsyncStream<Data> {
        return AsyncStream { continuation in
            self.continuation = continuation
            
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                
                audioEngine = AVAudioEngine()
                guard let engine = audioEngine else { return }
                
                let inputNode = engine.inputNode
                let inputFormat = inputNode.inputFormat(forBus: 0)
                
                guard let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
                    continuation.finish()
                    return
                }
                
                let targetFrameCapacity = AVAudioFrameCount(1600)
                var pcmBuffer = Data()
                
                inputNode.installTap(onBus: 0, bufferSize: 1600, format: inputFormat) { [weak self] (buffer, time) in
                    guard let self = self else { return }
                    
                    self.updateLocalActivity(buffer)
                    
                    let inputCallback: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                        outStatus.pointee = .haveData
                        return buffer
                    }
                    
                    let convertedBuffer = AVAudioPCMBuffer(pcmFormat: self.targetFormat, frameCapacity: targetFrameCapacity)!
                    var error: NSError? = nil
                    let status = converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputCallback)
                    
                    if status != .error, let channelData = convertedBuffer.int16ChannelData {
                        let length = Int(convertedBuffer.frameLength) * 2
                        let data = Data(bytes: channelData[0], count: length)
                        pcmBuffer.append(data)
                        
                        while pcmBuffer.count >= 1600 {
                            let chunk = pcmBuffer.prefix(1600)
                            pcmBuffer.removeFirst(1600)
                            continuation.yield(chunk)
                        }
                    }
                }
                
                try engine.start()
                isCapturing = true
                
            } catch {
                print("AudioCaptureService error: \(error)")
                continuation.finish()
            }
        }
    }
    
    func stopCapture() {
        guard isCapturing else { return }
        
        if let engine = audioEngine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        
        isCapturing = false
        continuation?.finish()
        continuation = nil
    }
    
    private func updateLocalActivity(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return }
        var sum: Float = 0
        let samples = channelData[0]
        for i in 0..<frameCount { sum += samples[i] * samples[i] }
        let rms = sqrt(sum / Float(frameCount))
        let activity: LocalSpeechActivity = rms > activityThreshold ? .speaking : .silent
        if activity != lastActivity {
            lastActivity = activity
            onLocalSpeechActivityChanged?(activity)
        }
    }
}
