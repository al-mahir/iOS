//
//  SFSpeechEvaluationService.swift
//  Mualem
//
//  Real-time Arabic speech recognition using SFSpeechRecognizer.
//  Captures live audio via AVAudioEngine, transcribes Arabic speech,
//  and maps recognized words against expected Ayah text for
//  word-by-word highlighting.
//

import Foundation
import Speech
import AVFoundation

public final class SFSpeechEvaluationService: VoiceEvaluationServiceProtocol {
    
    // MARK: - Configuration
    
    /// Silence timeout in seconds. If no new word is matched for this duration,
    /// the session auto-completes.
    private let silenceTimeout: TimeInterval = 3.0
    
    /// Arabic locale for speech recognition.
    private let locale = Locale(identifier: "ar-SA")
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Protocol
    
    public func evaluateStream(
        surah: Int,
        ayah: Int,
        expectedWords: [String],
        maxDuration: TimeInterval
    ) -> AsyncStream<RecitationEvent> {
        
        AsyncStream { continuation in
            Task {
                await self.runRecognitionSession(
                    surah: surah,
                    ayah: ayah,
                    expectedWords: expectedWords,
                    maxDuration: maxDuration,
                    continuation: continuation
                )
            }
        }
    }
    
    // MARK: - Recognition Session
    
    private func runRecognitionSession(
        surah: Int,
        ayah: Int,
        expectedWords: [String],
        maxDuration: TimeInterval,
        continuation: AsyncStream<RecitationEvent>.Continuation
    ) async {
        // 1. Check permissions
        let speechAuthorized = await requestSpeechAuthorization()
        guard speechAuthorized else {
            continuation.yield(.error(SpeechError.speechRecognitionDenied))
            continuation.finish()
            return
        }
        
        let micAuthorized = await requestMicrophoneAuthorization()
        guard micAuthorized else {
            continuation.yield(.error(SpeechError.microphoneDenied))
            continuation.finish()
            return
        }
        
        // 2. Configure recognizer
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            continuation.yield(.error(SpeechError.recognizerUnavailable))
            continuation.finish()
            return
        }
        
        // 3. Set up audio engine
        let audioEngine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // Prefer on-device recognition when available
        request.requiresOnDeviceRecognition = false
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            continuation.yield(.error(SpeechError.audioSessionFailed(error)))
            continuation.finish()
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            continuation.yield(.error(SpeechError.audioEngineFailed(error)))
            continuation.finish()
            return
        }
        
        // 4. State tracking
        var matchedWordCount = 0
        var lastMatchTime = Date()
        var isFinished = false
        
        let cleanup: () -> Void = {
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            request.endAudio()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        
        let finishSession: ([RecitationMistake]) -> Void = { mistakes in
            guard !isFinished else { return }
            isFinished = true
            cleanup()
            continuation.yield(.completed(mistakes: mistakes))
            continuation.finish()
        }
        
        // 5. Start recognition task
        let recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            guard !isFinished else { return }
            
            if let error = error {
                // Ignore cancellation errors (we trigger these on purpose)
                let nsError = error as NSError
                if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 216 {
                    // "kAFAssistantErrorDomain error 216" = recognition was cancelled
                    return
                }
                guard !isFinished else { return }
                isFinished = true
                cleanup()
                continuation.yield(.error(error))
                continuation.finish()
                return
            }
            
            guard let result else { return }
            
            let transcribedText = result.bestTranscription.formattedString
            let transcribedWords = Self.normalizeAndTokenize(transcribedText)
            
            // Sequential matching: find how many expected words match from the start
            let newMatchCount = Self.countSequentialMatches(
                expected: expectedWords,
                transcribed: transcribedWords
            )
            
            // Emit new word detections
            while matchedWordCount < newMatchCount {
                matchedWordCount += 1
                lastMatchTime = Date()
                // wordIndex is 1-based to match the Word entity convention
                continuation.yield(.wordDetected(wordIndex: matchedWordCount))
            }
            
            // Check if all words matched
            if matchedWordCount >= expectedWords.count {
                let mistakes = Self.generateMistakes(
                    expected: expectedWords,
                    transcribed: transcribedWords,
                    matchedCount: matchedWordCount
                )
                finishSession(mistakes)
            }
            
            // Check if result is final (recognizer decided to stop)
            if result.isFinal {
                let mistakes = Self.generateMistakes(
                    expected: expectedWords,
                    transcribed: transcribedWords,
                    matchedCount: matchedWordCount
                )
                finishSession(mistakes)
            }
        }
        
        // 6. Monitor silence timeout and max duration
        let startTime = Date()
        while !isFinished {
            try? await Task.sleep(nanoseconds: 500_000_000) // Check every 0.5s
            
            let elapsed = Date().timeIntervalSince(startTime)
            let silenceElapsed = Date().timeIntervalSince(lastMatchTime)
            
            // Max duration exceeded
            if elapsed >= maxDuration {
                recognitionTask.cancel()
                let mistakes = Self.generateMistakes(
                    expected: expectedWords,
                    transcribed: [],
                    matchedCount: matchedWordCount
                )
                finishSession(mistakes)
                break
            }
            
            // Silence timeout: only trigger after at least one word has been matched
            // (give the user time to start speaking)
            if matchedWordCount > 0 && silenceElapsed >= silenceTimeout {
                recognitionTask.cancel()
                let mistakes = Self.generateMistakes(
                    expected: expectedWords,
                    transcribed: [],
                    matchedCount: matchedWordCount
                )
                finishSession(mistakes)
                break
            }
        }
    }
    
    // MARK: - Word Matching
    
    /// Strips Arabic diacritics (tashkeel) and splits into whitespace-separated tokens.
    static func normalizeAndTokenize(_ text: String) -> [String] {
        let stripped = stripArabicDiacritics(text)
        return stripped.components(separatedBy: .whitespaces)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
    }
    
    /// Removes Arabic diacritical marks (tashkeel) from text.
    static func stripArabicDiacritics(_ text: String) -> String {
        // Arabic diacritics Unicode range: U+064B to U+065F, plus U+0670 (superscript alef)
        let diacritics = CharacterSet(charactersIn: "\u{064B}\u{064C}\u{064D}\u{064E}\u{064F}\u{0650}\u{0651}\u{0652}\u{0653}\u{0654}\u{0655}\u{0656}\u{0657}\u{0658}\u{0659}\u{065A}\u{065B}\u{065C}\u{065D}\u{065E}\u{065F}\u{0670}")
        return String(text.unicodeScalars.filter { !diacritics.contains($0) })
    }
    
    /// Counts how many expected words match sequentially from the beginning
    /// of the transcribed tokens. Uses fuzzy prefix matching for Arabic.
    static func countSequentialMatches(expected: [String], transcribed: [String]) -> Int {
        var expectedIdx = 0
        var transcribedIdx = 0
        
        while expectedIdx < expected.count && transcribedIdx < transcribed.count {
            let exp = stripArabicDiacritics(expected[expectedIdx]).trimmingCharacters(in: .whitespaces)
            let trans = transcribed[transcribedIdx].trimmingCharacters(in: .whitespaces)
            
            if exp == trans || levenshteinSimilarity(exp, trans) > 0.7 {
                expectedIdx += 1
            }
            transcribedIdx += 1
        }
        
        return expectedIdx
    }
    
    /// Basic Levenshtein similarity (0.0 to 1.0) for fuzzy Arabic matching.
    static func levenshteinSimilarity(_ s1: String, _ s2: String) -> Double {
        let a = Array(s1)
        let b = Array(s2)
        let m = a.count
        let n = b.count
        
        guard m > 0 && n > 0 else { return 0 }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }
        
        let distance = Double(matrix[m][n])
        let maxLen = Double(max(m, n))
        return 1.0 - (distance / maxLen)
    }
    
    /// Generates basic mistakes by comparing matched vs expected word count.
    static func generateMistakes(expected: [String], transcribed: [String], matchedCount: Int) -> [RecitationMistake] {
        var mistakes: [RecitationMistake] = []
        
        // Words that were not recited (skipped)
        if matchedCount < expected.count {
            for wordIdx in (matchedCount + 1)...expected.count {
                let desc = String(
                    format: NSLocalizedString("word_not_recited_format", bundle: .module, value: "Word %d was not recited.", comment: "Mistake description when word is skipped"),
                    wordIdx
                )
                mistakes.append(RecitationMistake(
                    type: .memorization,
                    wordIndex: wordIdx,
                    description: desc
                ))
            }
        }
        
        return mistakes
    }
    
    // MARK: - Permissions
    
    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    private func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

// MARK: - Error Types

public enum SpeechError: LocalizedError {
    case speechRecognitionDenied
    case microphoneDenied
    case recognizerUnavailable
    case audioSessionFailed(Error)
    case audioEngineFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .speechRecognitionDenied:
            return NSLocalizedString("error_speech_recognition_denied", bundle: .module, value: "Speech recognition permission was denied. Please enable it in Settings.", comment: "Permission error for speech recognition")
        case .microphoneDenied:
            return NSLocalizedString("error_microphone_denied", bundle: .module, value: "Microphone permission was denied. Please enable it in Settings.", comment: "Permission error for microphone")
        case .recognizerUnavailable:
            return NSLocalizedString("error_recognizer_unavailable", bundle: .module, value: "Arabic speech recognition is not available on this device.", comment: "Recognizer unavailable error")
        case .audioSessionFailed(let error):
            return String(
                format: NSLocalizedString("error_audio_session_failed_format", bundle: .module, value: "Audio session setup failed: %@", comment: "Audio session error"),
                error.localizedDescription
            )
        case .audioEngineFailed(let error):
            return String(
                format: NSLocalizedString("error_audio_engine_failed_format", bundle: .module, value: "Audio engine failed to start: %@", comment: "Audio engine error"),
                error.localizedDescription
            )
        }
    }
}
