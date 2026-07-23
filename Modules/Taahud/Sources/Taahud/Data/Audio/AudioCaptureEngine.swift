import AVFAudio

/// Local-only, UI-facing indicator of whether the user appears to be
/// speaking right now. This is NOT the server's VAD/endpointing and never
/// gates what audio gets sent — API.md is explicit that chunking and silence
/// trimming are entirely server-side. This exists purely so the UI can show
/// "listening…" (story 3), independent of the server's own decisions.
enum LocalSpeechActivity: Sendable {
    case speaking
    case silent
}

protocol AudioCapturing: AnyObject, Sendable {
    /// Fired continuously once capture starts (and stays paused-silent while
    /// `pause()` is in effect): 16kHz mono Int16 LE frames ready to stream.
    /// Marked `@Sendable` because it is invoked from the audio engine's own
    /// callback context, not necessarily the actor that set it.
    var onPCMFrame: (@Sendable (Data) -> Void)? { get set }
    /// UI-only hint, see `LocalSpeechActivity`.
    var onLocalSpeechActivityChanged: (@Sendable (LocalSpeechActivity) -> Void)? { get set }

    func start() throws
    /// Keeps the engine running but stops invoking `onPCMFrame`.
    func pause()
    func resume() throws
    func stop()
}

/// `@unchecked Sendable`: mutable state (`resampler`, `isSendingFrames`,
/// `lastActivity`) is only ever touched from the audio engine's serial
/// render/callback thread plus setup/teardown on the caller's thread before
/// or after that thread is running — never concurrently. The public
/// callbacks are themselves `@Sendable`.
final class AudioCaptureEngine: AudioCapturing, @unchecked Sendable {
    var onPCMFrame: (@Sendable (Data) -> Void)?
    var onLocalSpeechActivityChanged: (@Sendable (LocalSpeechActivity) -> Void)?

    private let engine = AVAudioEngine()
    private var resampler: PCM16Resampler?
    private var isSendingFrames = false
    private var lastActivity: LocalSpeechActivity = .silent

    /// Simple energy gate for the local-only indicator. Not used for anything
    /// sent to the server.
    private let activityThreshold: Float = 0.015

    func start() throws {
        let session = AVAudioSession.sharedInstance()
        // .measurement disables system-applied noise suppression/AGC, which
        // otherwise distorts the sustained vowels madd grading measures
        // (API.md §10, iOS notes).
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
        try session.setActive(true)

        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)
        resampler = try PCM16Resampler(inputFormat: inputFormat)

        input.installTap(onBus: 0, bufferSize: 1600, format: inputFormat) { [weak self] buffer, _ in
            self?.handle(buffer: buffer)
        }

        engine.prepare()
        try engine.start()
        isSendingFrames = true
    }

    func pause() {
        isSendingFrames = false
    }

    func resume() throws {
        if !engine.isRunning {
            try engine.start()
        }
        isSendingFrames = true
    }

    func stop() {
        isSendingFrames = false
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func handle(buffer: AVAudioPCMBuffer) {
        updateLocalActivity(buffer)

        guard isSendingFrames, let resampler else { return }
        guard let data = try? resampler.resample(buffer) else { return }
        onPCMFrame?(data)
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
