import Foundation

/// Story 14: Save Session History. Simple per-session JSON file on disk.
/// Swap for CoreData/SwiftData later without touching the domain layer —
/// only this file and its private DTOs would change.
final class SessionHistoryRepositoryImpl: SessionHistoryRepository, @unchecked Sendable {
    private let directory: URL
    private let fileManager = FileManager.default

    init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            self.directory = base.appendingPathComponent("TaahudSessions", isDirectory: true)
        }
        try? fileManager.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func save(_ summary: SessionSummary) async throws {
        let dto = SessionSummaryDTO(from: summary)
        let data = try JSONEncoder().encode(dto)
        try data.write(to: fileURL(for: summary.id), options: .atomic)
    }

    func fetchAll() async throws -> [SessionSummary] {
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let dto = try? JSONDecoder().decode(SessionSummaryDTO.self, from: data) else { return nil }
                return dto.toDomain()
            }
            .sorted { $0.startedAt > $1.startedAt }
    }

    func fetch(id: String) async throws -> SessionSummary? {
        guard let data = try? Data(contentsOf: fileURL(for: id)) else { return nil }
        return try? JSONDecoder().decode(SessionSummaryDTO.self, from: data).toDomain()
    }

    func delete(id: String) async throws {
        try? fileManager.removeItem(at: fileURL(for: id))
    }

    private func fileURL(for id: String) -> URL {
        directory.appendingPathComponent("\(id).json")
    }
}

// MARK: - Persistence DTOs
// Kept separate from the domain models on purpose: the domain layer has no
// business knowing how it gets serialized to disk.

private struct RangeDTO: Codable {
    let lower: Int
    let upper: Int
    init(_ range: ClosedRange<Int>) { lower = range.lowerBound; upper = range.upperBound }
    var range: ClosedRange<Int> { lower...upper }
}

private struct TajweedRuleMatchDTOP: Codable {
    let nameAr, nameEn: String
    let goldenLen: Int?
    let correctnessType: String
    let tag: String?
    init(_ m: TajweedRuleMatch) {
        nameAr = m.nameAr; nameEn = m.nameEn; goldenLen = m.goldenLen
        correctnessType = m.correctnessType.rawValue; tag = m.tag
    }
    func toDomain() -> TajweedRuleMatch {
        TajweedRuleMatch(nameAr: nameAr, nameEn: nameEn, goldenLen: goldenLen,
                          correctnessType: RuleCorrectnessType(rawValue: correctnessType) ?? .match, tag: tag)
    }
}

private struct RecognitionErrorDTOP: Codable {
    let errorType: String
    let speechErrorType: String
    let uthmaniRange: RangeDTO
    let phRange: RangeDTO
    let predPhRange: RangeDTO?
    let expectedPh, predictedPh: String
    let expectedLen, predictedLen: Int?
    let tajweedRules: [TajweedRuleMatchDTOP]
    let confidence: Double?

    init(_ e: RecognitionError) {
        errorType = e.errorType.rawValue
        speechErrorType = e.speechErrorType.rawValue
        uthmaniRange = RangeDTO(e.uthmaniRange)
        phRange = RangeDTO(e.phRange)
        predPhRange = e.predPhRange.map(RangeDTO.init)
        expectedPh = e.expectedPh; predictedPh = e.predictedPh
        expectedLen = e.expectedLen; predictedLen = e.predictedLen
        tajweedRules = e.tajweedRules.map(TajweedRuleMatchDTOP.init)
        confidence = e.confidence
    }

    func toDomain() -> RecognitionError {
        RecognitionError(
            errorType: ErrorChannel(rawValue: errorType) ?? .normal,
            speechErrorType: SpeechErrorType(rawValue: speechErrorType) ?? .replace,
            uthmaniRange: uthmaniRange.range,
            phRange: phRange.range,
            predPhRange: predPhRange?.range,
            expectedPh: expectedPh, predictedPh: predictedPh,
            expectedLen: expectedLen, predictedLen: predictedLen,
            tajweedRules: tajweedRules.map { $0.toDomain() },
            confidence: confidence
        )
    }
}

private struct WordFeedbackDTOP: Codable {
    let sura, aya, wordIdx: Int
    let uthmani: String
    let status: String
    let errors: [RecognitionErrorDTOP]
    let trimmed: Bool

    init(_ w: WordFeedback) {
        sura = w.sura; aya = w.aya; wordIdx = w.wordIdx; uthmani = w.uthmani
        status = w.status.rawValue; errors = w.errors.map(RecognitionErrorDTOP.init); trimmed = w.trimmed
    }
    func toDomain() -> WordFeedback {
        WordFeedback(sura: sura, aya: aya, wordIdx: wordIdx, uthmani: uthmani,
                     status: WordStatus(rawValue: status) ?? .almost,
                     errors: errors.map { $0.toDomain() }, trimmed: trimmed)
    }
}

private struct MistakeRecordDTO: Codable {
    let word: WordFeedbackDTOP
    let error: RecognitionErrorDTOP
    let sura, aya, wordIdx: Int

    init(_ m: MistakeRecord) {
        word = WordFeedbackDTOP(m.word); error = RecognitionErrorDTOP(m.error)
        sura = m.occurredAt.sura; aya = m.occurredAt.aya; wordIdx = m.occurredAt.wordIdx
    }
    func toDomain() -> MistakeRecord {
        MistakeRecord(word: word.toDomain(), error: error.toDomain(),
                      occurredAt: MushafPosition(sura: sura, aya: aya, wordIdx: wordIdx))
    }
}

private struct PositionDTOP: Codable {
    let sura, aya, wordIdx: Int
    init(_ p: MushafPosition) { sura = p.sura; aya = p.aya; wordIdx = p.wordIdx }
    func toDomain() -> MushafPosition { MushafPosition(sura: sura, aya: aya, wordIdx: wordIdx) }
}

private struct AyahRevisionDTO: Codable {
    let sura, aya, mistakeCount: Int
    init(_ s: AyahRevisionSuggestion) { sura = s.sura; aya = s.aya; mistakeCount = s.mistakeCount }
    func toDomain() -> AyahRevisionSuggestion { AyahRevisionSuggestion(sura: sura, aya: aya, mistakeCount: mistakeCount) }
}

private struct RuleRevisionDTO: Codable {
    let ruleKeyOrName, nameAr: String
    let occurrences: Int
    init(_ s: RuleRevisionSuggestion) { ruleKeyOrName = s.ruleKeyOrName; nameAr = s.nameAr; occurrences = s.occurrences }
    func toDomain() -> RuleRevisionSuggestion { RuleRevisionSuggestion(ruleKeyOrName: ruleKeyOrName, nameAr: nameAr, occurrences: occurrences) }
}

private struct RevisionPlanDTO: Codable {
    let ayahsToReview: [AyahRevisionDTO]
    let rulesToReview: [RuleRevisionDTO]
    let frequentMistakeDescriptions: [String]
    init(_ p: RevisionPlan) {
        ayahsToReview = p.ayahsToReview.map(AyahRevisionDTO.init)
        rulesToReview = p.rulesToReview.map(RuleRevisionDTO.init)
        frequentMistakeDescriptions = p.frequentMistakeDescriptions
    }
    func toDomain() -> RevisionPlan {
        RevisionPlan(ayahsToReview: ayahsToReview.map { $0.toDomain() },
                      rulesToReview: rulesToReview.map { $0.toDomain() },
                      frequentMistakeDescriptions: frequentMistakeDescriptions)
    }
}

private struct SessionSummaryDTO: Codable {
    let id: String
    let startedAt, endedAt: Date
    let engineUsed, strictness: String
    let startPosition, lastCursor: PositionDTOP?
    let totalWordsScored, correctWords, hintedWords, mistakeWords: Int
    let mistakes: [MistakeRecordDTO]
    let revisionPlan: RevisionPlanDTO

    init(from s: SessionSummary) {
        id = s.id; startedAt = s.startedAt; endedAt = s.endedAt
        engineUsed = s.engineUsed.rawValue; strictness = s.strictness.rawValue
        startPosition = s.startPosition.map(PositionDTOP.init)
        lastCursor = s.lastCursor.map(PositionDTOP.init)
        totalWordsScored = s.totalWordsScored; correctWords = s.correctWords
        hintedWords = s.hintedWords; mistakeWords = s.mistakeWords
        mistakes = s.mistakes.map(MistakeRecordDTO.init)
        revisionPlan = RevisionPlanDTO(s.revisionPlan)
    }

    func toDomain() -> SessionSummary {
        SessionSummary(
            id: id, startedAt: startedAt, endedAt: endedAt,
            engineUsed: ASREngine(rawValue: engineUsed) ?? .mock,
            strictness: Strictness(rawValue: strictness) ?? .normal,
            startPosition: startPosition?.toDomain(), lastCursor: lastCursor?.toDomain(),
            totalWordsScored: totalWordsScored, correctWords: correctWords,
            hintedWords: hintedWords, mistakeWords: mistakeWords,
            mistakes: mistakes.map { $0.toDomain() },
            revisionPlan: revisionPlan.toDomain()
        )
    }
}
