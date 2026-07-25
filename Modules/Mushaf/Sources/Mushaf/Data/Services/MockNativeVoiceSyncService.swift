//
//  MockNativeVoiceSyncService.swift
//  Mushaf
//
//  Created for Mock Voice Reading Mode.
//

import Foundation
import Speech
import AVFoundation

public final class MockNativeVoiceSyncService: VoiceSyncManagerProtocol {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var streamContinuation: AsyncStream<String?>.Continuation?
    public lazy var highlightedWordKey: AsyncStream<String?> = {
        AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }()
    
    public init() {}
    
    public func startListening(targetSurah: Int, targetAyah: Int, targetText: String) async throws {
        stopListening()
        
        let authStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        guard authStatus == .authorized else {
            throw NSError(domain: "VoiceSyncError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"])
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceSyncError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Setup target words for mock synchronization
        let targetWords = targetText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        var currentWordIndex = 0
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                // Number of recognized words
                let spokenWords = result.bestTranscription.segments
                
                // Simple heuristic: advance highlight as words are recognized
                // In a real app, this would use a complex Levenshtein distance or forced alignment
                if spokenWords.count > currentWordIndex && currentWordIndex < targetWords.count {
                    let wordKey = "\(targetSurah)_\(targetAyah)_\(currentWordIndex + 1)"
                    self.streamContinuation?.yield(wordKey)
                    currentWordIndex += 1
                } else if currentWordIndex >= targetWords.count {
                    self.streamContinuation?.yield(nil)
                    self.stopListening()
                }
            }
            
            if error != nil || result?.isFinal == true {
                self.stopListening()
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    public func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        streamContinuation?.yield(nil)
    }
}
