//
//  SpeechService.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//

import Speech
import AVFoundation
import Combine

@MainActor
class SpeechService: ObservableObject {

    @Published var transcript = ""
    @Published var isListening = false
    @Published var error: String?

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    func requestPermissions() async -> Bool {
        print("🔍 Requesting permissions...")
        
        // Check if speech recognition is available
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")),
              recognizer.isAvailable else {
            error = "Speech recognition is not available on this device."
            print("❌ Speech recognition not available")
            return false
        }
        
        // Request microphone permission
        let micGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                print("🎤 Microphone permission: \(granted ? "Granted" : "Denied")")
                continuation.resume(returning: granted)
            }
        }
        
        guard micGranted else {
            error = "Microphone access denied."
            return false
        }

        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                print("🎙️ Speech recognition authorization: \(status.rawValue)")
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            error = "Speech recognition access denied."
            return false
        }

        print("✅ All permissions granted")
        return true
    }

    func startListening() async {
        print("🎤 Starting listening...")
        stopListening()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured")

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else {
                print("❌ Failed to create recognition request")
                return
            }
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false // Try with this set to false

            let inputNode = audioEngine.inputNode
            print("✅ Input node ready")

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self else { return }

                if let result {
                    let transcriptText = result.bestTranscription.formattedString
                    print("📝 Partial result: \(transcriptText)")
                    
                    Task { @MainActor in
                        self.transcript = transcriptText
                        print("📝 Updated transcript to: \(transcriptText)")
                    }
                }

                if let error = error {
                    print("❌ Recognition error: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.error = error.localizedDescription
                        self.stopListening()
                    }
                }

                if result?.isFinal == true {
                    print("✅ Recognition final result")
                    Task { @MainActor in
                        self.stopListening()
                    }
                }
            }

            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                recognitionRequest.append(buffer)
                // This prints a lot, so only uncomment for debugging
                // print("🔊 Audio buffer received")
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            print("✅ Audio engine started, listening...")
            
            // Auto-stop after 5 seconds
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            print("⏰ Auto-stop after 5 seconds")
            stopListening()

        } catch {
            print("❌ Start listening error: \(error.localizedDescription)")
            self.error = error.localizedDescription
            isListening = false
        }
    }

    func stopListening() {
        print("🛑 Stopping listening...")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        print("✅ Stopped listening")
    }
}
