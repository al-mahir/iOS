//
//  RecitationRepository.swift
//  Taahud

import Foundation

public struct RecitationStartConfig: Equatable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int
    public let strictness: RecitationStrictness
    public let engine: RecitationEngine
    public let rules: [TajweedRule]

    public init(sura: Int, aya: Int, wordIdx: Int,
                strictness: RecitationStrictness = .normal,
                engine: RecitationEngine = .real,
                rules: [TajweedRule] = [.aaredMadd, .ghonna]) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
        self.strictness = strictness
        self.engine = engine
        self.rules = rules
    }
}

public protocol RecitationRepository {

    func startSession(config: RecitationStartConfig) async throws -> RecitationSession

    func feedbackEvents() -> AsyncThrowingStream<RecitationFeedbackEvent, Error>

    func sendAudioFrame(_ data: Data) async throws

    func seek(sura: Int, aya: Int, wordIdx: Int) async throws

    func stopSession() async throws
}
