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
    private var pendingWordItem: DispatchWorkItem?
 
    private let fillerWords: Set<String> = ["و", "ف", "ب", "ل", "ك", "س", "قد", "لا", "ما", "من", "عن", "على", "إلى"]
 
    // How long the last word must stay unchanged before we treat it as "finished
    // being spoken" and send it for evaluation. Lower = snappier but more risk of
    // evaluating a half-formed word; higher = safer but feels laggier.
    private let wordSettleDelay: TimeInterval = 0.45
 
    init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
        print("🎙️ [Speech] init - recognizer available: \(speechRecognizer?.isAvailable ?? false)")
        if #available(iOS 13.0, *) {
            print("🎙️ [Speech] supportsOnDeviceRecognition: \(speechRecognizer?.supportsOnDeviceRecognition ?? false)")
        }
    }
 
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            print("🎙️ [Speech] authorization status: \(status.rawValue)")
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
        print("🎙️ [Speech] startRecording called")
        self.onTextReceived = onTextReceived
        self.lastSentText = ""
        self.shouldAllowRetry = false
        self.recognizedText = ""
        pendingWordItem?.cancel()
 
        recognitionTask?.cancel()
        recognitionTask = nil
 
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
 
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ [Speech] audio session error: \(error.localizedDescription)")
            self.error = error
            return
        }
 
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ [Speech] recognizer is nil or not available right now")
            return
        }
 
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("❌ [Speech] failed to create recognitionRequest")
            return
        }
        recognitionRequest.shouldReportPartialResults = true
 
        if #available(iOS 13.0, *) {
            // Only force on-device recognition when this locale actually supports it.
            // Forcing it when unsupported fails silently - the task runs, the mic
            // animates, but no results (and often no error either) ever arrive.
            let supportsOnDevice = speechRecognizer.supportsOnDeviceRecognition
            recognitionRequest.requiresOnDeviceRecognition = supportsOnDevice
            print("🎙️ [Speech] requiresOnDeviceRecognition = \(supportsOnDevice)")
        }
 
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
 
            if let error = error {
                let nsError = error as NSError
                print("❌ [Speech] recognitionTask error: domain=\(nsError.domain) code=\(nsError.code) msg=\(error.localizedDescription)")
                DispatchQueue.main.async { self.error = error }
            }
 
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                print("🗣️ [Speech] partial='\(spokenText)' isFinal=\(result.isFinal)")
 
                DispatchQueue.main.async {
                    self.recognizedText = spokenText
                    if !spokenText.isEmpty {
                        self.processText(spokenText, isFinal: result.isFinal)
                    }
                }
            }
        }
 
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
 
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("🎙️ [Speech] audio engine started")
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("❌ [Speech] audio engine start error: \(error.localizedDescription)")
            self.error = error
            stopRecording()
        }
    }
 
    /// Apple's partial results keep re-guessing the last word while the person is still
    /// mid-word. Rather than requiring a *next* word to start (which never happens if the
    /// person says one word and waits for feedback, like this app does), we debounce: the
    /// last word is sent once it stops changing for `wordSettleDelay` seconds, or
    /// immediately once the recognizer marks the result final.
    private func processText(_ text: String, isFinal: Bool) {
        let words = text.split(separator: " ").map(String.init)
        guard let lastWord = words.last else { return }
 
        pendingWordItem?.cancel()
 
        if isFinal {
            print("✅ [Speech] isFinal - sending immediately: '\(lastWord)'")
            send(lastWord)
            return
        }
 
        let workItem = DispatchWorkItem { [weak self] in
            print("⏱️ [Speech] word settled after debounce: '\(lastWord)'")
            self?.send(lastWord)
        }
        pendingWordItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + wordSettleDelay, execute: workItem)
    }
 
    private func send(_ word: String) {
        guard word.count >= 2 else {
            print("⏭️ [Speech] skipping short word: '\(word)'")
            return
        }
        guard !fillerWords.contains(word) else {
            print("⏭️ [Speech] skipping filler word: '\(word)'")
            return
        }
 
        let isNewWord = word != lastSentText
        if isNewWord || shouldAllowRetry {
            print("📤 [Speech] sending word to evaluator: '\(word)' (retry=\(shouldAllowRetry))")
            lastSentText = word
            shouldAllowRetry = false
            onTextReceived?(word)
        } else {
            print("⏭️ [Speech] skipping repeat of last sent word: '\(word)'")
        }
    }
 
    func allowRetry() {
        print("🔁 [Speech] allowRetry")
        shouldAllowRetry = true
        lastSentText = ""
    }
 
    func stopRecording() {
        print("🎙️ [Speech] stopRecording called")
        pendingWordItem?.cancel()
 
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
 
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
 
        recognitionRequest = nil
        recognitionTask = nil
 
        // Set synchronously (we're already on the main thread whenever this is called
        // from the view). Dispatching this async let it race with - and clobber - the
        // onTextReceived closure set by an immediately-following startRecording() call.
        isRecording = false
        onTextReceived = nil
    }
}
