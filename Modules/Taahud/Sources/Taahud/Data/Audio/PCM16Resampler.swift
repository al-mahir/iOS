import AVFAudio

enum ResamplerError: Error {
    case formatUnsupported
    case converterUnavailable
    case conversionFailed
}

/// Converts whatever format the hardware taps at (commonly 48kHz Float32) to
/// the exact wire format the server requires (API.md §5.3): 16kHz, mono,
/// signed 16-bit PCM, little-endian, no container.
final class PCM16Resampler {
    private let converter: AVAudioConverter
    private let outputFormat: AVAudioFormat

    init(inputFormat: AVAudioFormat) throws {
        guard let outputFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 16000,
            channels: 1,
            interleaved: true
        ) else {
            throw ResamplerError.formatUnsupported
        }
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw ResamplerError.converterUnavailable
        }
        self.converter = converter
        self.outputFormat = outputFormat
    }

    /// Returns raw little-endian Int16 PCM bytes ready for a binary WS frame.
    func resample(_ inputBuffer: AVAudioPCMBuffer) throws -> Data {
        let ratio = outputFormat.sampleRate / inputBuffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio) + 16
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: capacity) else {
            throw ResamplerError.conversionFailed
        }

        var error: NSError?
        var consumed = false
        let status = converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            if consumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            consumed = true
            outStatus.pointee = .haveData
            return inputBuffer
        }

        guard status != .error, error == nil else { throw ResamplerError.conversionFailed }
        guard let channelData = outputBuffer.int16ChannelData else { throw ResamplerError.conversionFailed }

        let frameCount = Int(outputBuffer.frameLength)
        // Int16 is little-endian on every Apple Silicon and Intel device, so
        // the raw buffer bytes go out as-is (API.md §10, iOS notes).
        return Data(bytes: channelData[0], count: frameCount * MemoryLayout<Int16>.size)
    }
}
