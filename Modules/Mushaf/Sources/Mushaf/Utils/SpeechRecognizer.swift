//
//  SpeechRecognizer.swift
//  Mushaf
//
//  Created by Alaa Ayman on 22/07/2026.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var error: Error?
    
    private var onTextReceived: ((String) -> Void)?
    private var lastSentText = ""
    private var shouldAllowRetry = false
    
    init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
        if #available(iOS 13.0, *) {
            speechRecognizer?.supportsOnDeviceRecognition = true
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    func startRecording(onTextReceived: @escaping (String) -> Void) {
        self.onTextReceived = onTextReceived
        self.lastSentText = ""
        self.shouldAllowRetry = false
        self.recognizedText = ""
        
        // Cancel existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Stop audio engine if running
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = error
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                
                DispatchQueue.main.async {
                    self.recognizedText = spokenText
                    
                    if !spokenText.isEmpty {
                        // Process the text
                        self.processText(spokenText)
                    }
                }
            }
            
            if let error = error {
                print("Speech error: \(error.localizedDescription)")
            }
        }
        
        // Configure audio input
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            self.error = error
            stopRecording()
        }
    }
    
    private func processText(_ text: String) {
        // Get the last word from the recognized text
        let words = text.split(separator: " ").map(String.init)
        guard let lastWord = words.last else { return }
        
        // Skip short words
        if lastWord.count < 2 { return }
        
        // Skip filler words
        let fillerWords = ["و", "ف", "ب", "ل", "ك", "س", "قد", "لا", "ما", "من", "عن", "على", "إلى"]
        if fillerWords.contains(lastWord) { return }
        
        // Check if we should send this word
        let isNewWord = lastWord != lastSentText
        let isRetry = shouldAllowRetry
        
        if isNewWord || isRetry {
            lastSentText = lastWord
            shouldAllowRetry = false
            onTextReceived?(lastWord)
        }
    }
    
    func allowRetry() {
        shouldAllowRetry = true
        lastSentText = ""
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.onTextReceived = nil
        }
    }
}
