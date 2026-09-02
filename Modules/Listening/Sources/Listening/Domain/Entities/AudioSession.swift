//
//  AudioSession.swift
//  Listening
//

import Foundation

/// Lightweight value type capturing the current listening session state
public struct AudioSession: Sendable {
    public let reciter: Reciter
    public let chapterNumber: Int
    public let chapterName: String
    public let audioURL: URL
    public let wordTimings: [WordTiming]

    public init(
        reciter: Reciter,
        chapterNumber: Int,
        chapterName: String,
        audioURL: URL,
        wordTimings: [WordTiming]
    ) {
        self.reciter = reciter
        self.chapterNumber = chapterNumber
        self.chapterName = chapterName
        self.audioURL = audioURL
        self.wordTimings = wordTimings
    }
}

/// Playback state of the audio engine
public enum PlaybackState: Equatable, Sendable {
    case idle
    case loading
    case playing
    case paused
    case finished
    case error(String)
}

/// Playback speed options
public enum PlaybackSpeed: Double, CaseIterable, Identifiable, Sendable {
    case slow   = 0.75
    case normal = 1.0
    case fast   = 1.25
    case faster = 1.5

    public var id: Double { rawValue }

    public var label: String {
        switch self {
        case .slow:   return "0.75×"
        case .normal: return "1×"
        case .fast:   return "1.25×"
        case .faster: return "1.5×"
        }
    }
}
