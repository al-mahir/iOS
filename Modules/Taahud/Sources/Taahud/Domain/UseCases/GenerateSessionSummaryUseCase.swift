import Foundation

/// Story 10 (Finish Session: "Generate summary automatically") and story 11
/// (View Session Summary). Consumes every feedback event seen during a
/// session and produces the reviewable result.
///
/// Follows the same rendering contract as the live view: `almost` words are
/// never mistakes, `trimmed` words are never scored either direction,
/// `ambiguous`/`no_match` chunks contribute nothing.
public struct GenerateSessionSummaryUseCase: Sendable {
    private let suggestRevision: SuggestRevisionUseCase

    public init(suggestRevision: SuggestRevisionUseCase = SuggestRevisionUseCase()) {
        self.suggestRevision = suggestRevision
    }

    public func execute(
        sessionId: String,
        startedAt: Date,
        endedAt: Date,
        engineUsed: ASREngine,
        strictness: Strictness,
        startPosition: MushafPosition?,
        events: [FeedbackEvent]
    ) -> SessionSummary {
        var correct = 0, hinted = 0, mistaken = 0, scored = 0
        var mistakes: [MistakeRecord] = []
        var lastCursor: MushafPosition?

        for event in events {
            if let cursor = event.cursor { lastCursor = cursor }

            // ambiguous / no_match assert nothing — skip entirely.
            guard event.feedback.status == .ok else { continue }

            for word in event.feedback.words {
                if word.trimmed { continue } // unverified, not scored
                scored += 1
                switch word.status {
                case .correct:
                    correct += 1
                case .almost:
                    hinted += 1 // hint only, never a mistake
                case .error:
                    mistaken += 1
                    for error in word.errors {
                        mistakes.append(MistakeRecord(word: word, error: error, occurredAt: word.mushafPosition))
                    }
                }
            }
        }

        let plan = suggestRevision.execute(mistakes: mistakes)

        return SessionSummary(
            id: sessionId,
            startedAt: startedAt,
            endedAt: endedAt,
            engineUsed: engineUsed,
            strictness: strictness,
            startPosition: startPosition,
            lastCursor: lastCursor,
            totalWordsScored: scored,
            correctWords: correct,
            hintedWords: hinted,
            mistakeWords: mistaken,
            mistakes: mistakes,
            revisionPlan: plan
        )
    }
}
