import Foundation

/// Canned recitation feedback for demoing/testing the whole feature without
/// a live AI server. Uses Al-Fātiḥah 2–3 as recognisable, uncontroversial
/// reference text. Deliberately touches every mistake category called out in
/// the user stories, plus one of each rendering state (correct / almost /
/// error / trimmed / ambiguous), so every screen has something to show.
enum MockRecitationScript {

    private static func rule(_ nameAr: String, _ nameEn: String, golden: Int? = nil, tag: String? = nil) -> TajweedRuleMatch {
        TajweedRuleMatch(nameAr: nameAr, nameEn: nameEn, goldenLen: golden, correctnessType: .match, tag: tag)
    }

    private static func error(
        _ channel: ErrorChannel,
        _ speechType: SpeechErrorType,
        uthmani: ClosedRange<Int>,
        ph: ClosedRange<Int>,
        expected: String,
        predicted: String,
        rules: [TajweedRuleMatch] = [],
        confidence: Double? = 0.82
    ) -> RecognitionError {
        RecognitionError(
            errorType: channel, speechErrorType: speechType,
            uthmaniRange: uthmani, phRange: ph, predPhRange: ph,
            expectedPh: expected, predictedPh: predicted,
            expectedLen: nil, predictedLen: nil,
            tajweedRules: rules, confidence: confidence
        )
    }

    /// One scripted event per line below. Interval and pause behaviour lives
    /// in `MockRecitationSessionRepositoryImpl`, not here.
    static let events: [FeedbackEvent] = [

        // 1) Two clean words: الحمد لله — everything correct.
        FeedbackEvent(
            chunkSeq: 0, audioSpanSec: 0.0...1.4, forcedCut: false,
            phonemes: "alhamdu lillaahi",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 2, wordIdx: 0), end: MushafPosition(sura: 1, aya: 2, wordIdx: 1),
                uthmaniText: "الحمد لله", predictedPhonemes: "alhamdu lillaahi", referencePhonemes: "alhamdu lillaahi",
                words: [
                    WordFeedback(sura: 1, aya: 2, wordIdx: 0, uthmani: "الحمد", status: .correct, errors: [], trimmed: false),
                    WordFeedback(sura: 1, aya: 2, wordIdx: 1, uthmani: "لله", status: .correct, errors: [], trimmed: false),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 2, wordIdx: 2)
        ),

        // 2) رب — tashkeel mistake: missing vowel, low-confidence -> hint only (almost).
        FeedbackEvent(
            chunkSeq: 1, audioSpanSec: 1.4...2.1, forcedCut: false,
            phonemes: "rab",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 2, wordIdx: 2), end: MushafPosition(sura: 1, aya: 2, wordIdx: 2),
                uthmaniText: "رب", predictedPhonemes: "rab", referencePhonemes: "rabbi",
                words: [
                    WordFeedback(
                        sura: 1, aya: 2, wordIdx: 2, uthmani: "رب", status: .almost,
                        errors: [error(.tashkeel, .replace, uthmani: 6...6, ph: 2...2, expected: "bi", predicted: "b", confidence: 0.41)],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 2, wordIdx: 3)
        ),

        // 3) العالمين — clear ḥifẓ mistake: wrong word (hard error, high confidence).
        FeedbackEvent(
            chunkSeq: 2, audioSpanSec: 2.1...3.0, forcedCut: false,
            phonemes: "alaalameen",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 2, wordIdx: 3), end: MushafPosition(sura: 1, aya: 2, wordIdx: 3),
                uthmaniText: "العالمين", predictedPhonemes: "alaalameen", referencePhonemes: "alAAaalameen",
                words: [
                    WordFeedback(
                        sura: 1, aya: 2, wordIdx: 3, uthmani: "العالمين", status: .error,
                        errors: [error(.normal, .replace, uthmani: 7...15, ph: 3...10, expected: "alAAaalameen", predicted: "alaalameen", confidence: 0.93)],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 3, wordIdx: 0)
        ),

        // 4) الرحمن — tajwīd mistake bundle: madd + ghunnah shortfall on one word.
        FeedbackEvent(
            chunkSeq: 3, audioSpanSec: 3.0...3.9, forcedCut: false,
            phonemes: "arrahman",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 3, wordIdx: 0), end: MushafPosition(sura: 1, aya: 3, wordIdx: 0),
                uthmaniText: "الرحمن", predictedPhonemes: "arrahman", referencePhonemes: "arrahmaan",
                words: [
                    WordFeedback(
                        sura: 1, aya: 3, wordIdx: 0, uthmani: "الرحمن", status: .error,
                        errors: [error(
                            .tajweed, .replace, uthmani: 16...21, ph: 11...18,
                            expected: "rahmaan", predicted: "rahman",
                            rules: [rule("مد", "madd", golden: 4, tag: "madd_asli"), rule("غنة", "ghunnah", golden: 2, tag: "ghunnah")],
                            confidence: 0.88
                        )],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 3, wordIdx: 1)
        ),

        // 5) الرحيم — extra word inserted before it (story: Extra word), plus a
        //    second tajwīd rule family (qalqalah) shown standalone.
        FeedbackEvent(
            chunkSeq: 4, audioSpanSec: 3.9...5.0, forcedCut: false,
            phonemes: "wa arraheem",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 3, wordIdx: 1), end: MushafPosition(sura: 1, aya: 3, wordIdx: 1),
                uthmaniText: "الرحيم", predictedPhonemes: "wa arraheem", referencePhonemes: "arraheem",
                words: [
                    WordFeedback(
                        sura: 1, aya: 3, wordIdx: 1, uthmani: "الرحيم", status: .error,
                        errors: [
                            error(.normal, .insert, uthmani: 22...22, ph: 19...20, expected: "", predicted: "wa", confidence: 0.9),
                            error(.tajweed, .replace, uthmani: 23...28, ph: 21...27, expected: "raheem", predicted: "raheem",
                                  rules: [rule("قلقلة", "qalqalah", golden: 1, tag: "qalqalah_sughra")], confidence: 0.55),
                        ],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 3, wordIdx: 2)
        ),

        // 6) مالك — missing word entirely (story: Missing word), reported
        //    against the position it should have occupied.
        FeedbackEvent(
            chunkSeq: 5, audioSpanSec: 5.0...5.4, forcedCut: false,
            phonemes: "",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 4, wordIdx: 0), end: MushafPosition(sura: 1, aya: 4, wordIdx: 0),
                uthmaniText: "مالك", predictedPhonemes: "", referencePhonemes: "maaliki",
                words: [
                    WordFeedback(
                        sura: 1, aya: 4, wordIdx: 0, uthmani: "مالك", status: .error,
                        errors: [error(.normal, .delete, uthmani: 29...32, ph: 28...34, expected: "maaliki", predicted: "", confidence: 0.97)],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 4, wordIdx: 1)
        ),

        // 7) يوم الدين — last word arrived on a chunk boundary: unscored/neutral (trimmed).
        FeedbackEvent(
            chunkSeq: 6, audioSpanSec: 5.4...6.2, forcedCut: true,
            phonemes: "yawmi addeen",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 4, wordIdx: 1), end: MushafPosition(sura: 1, aya: 4, wordIdx: 2),
                uthmaniText: "يوم الدين", predictedPhonemes: "yawmi addeen", referencePhonemes: "yawmi addeen",
                words: [
                    WordFeedback(sura: 1, aya: 4, wordIdx: 1, uthmani: "يوم", status: .correct, errors: [], trimmed: false),
                    WordFeedback(sura: 1, aya: 4, wordIdx: 2, uthmani: "الدين", status: .correct, errors: [], trimmed: true),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 4, wordIdx: 2)
        ),

        // 8) Ambiguous chunk: server offers candidates, nothing is marked.
        FeedbackEvent(
            chunkSeq: 7, audioSpanSec: 6.2...6.9, forcedCut: false,
            phonemes: "iyyaka",
            feedback: FeedbackPayload(
                status: .ambiguous, span: nil, end: nil,
                uthmaniText: nil, predictedPhonemes: "iyyaka", referencePhonemes: "",
                words: [],
                candidates: [
                    RecognitionCandidate(sura: 1, aya: 5, wordIdx: 0, uthmaniText: "إياك", end: MushafPosition(sura: 1, aya: 5, wordIdx: 0)),
                    RecognitionCandidate(sura: 1, aya: 5, wordIdx: 1, uthmaniText: "نعبد", end: MushafPosition(sura: 1, aya: 5, wordIdx: 1)),
                ],
                nonVerse: []
            ),
            cursor: nil
        ),

        // 9) العالمين reappears in a later verse's echo drill — same wrong-word
        //    slip as event #3, so the revision plan's "frequently repeated"
        //    bucket has something real to surface (only hard `.error`s are
        //    counted as mistakes; `.almost` never is).
        FeedbackEvent(
            chunkSeq: 8, audioSpanSec: 6.9...7.5, forcedCut: false,
            phonemes: "alaalameen",
            feedback: FeedbackPayload(
                status: .ok, span: MushafPosition(sura: 1, aya: 5, wordIdx: 0), end: MushafPosition(sura: 1, aya: 5, wordIdx: 0),
                uthmaniText: "العالمين", predictedPhonemes: "alaalameen", referencePhonemes: "alAAaalameen",
                words: [
                    WordFeedback(
                        sura: 1, aya: 5, wordIdx: 0, uthmani: "العالمين", status: .error,
                        errors: [error(.normal, .replace, uthmani: 7...15, ph: 3...10, expected: "alAAaalameen", predicted: "alaalameen", confidence: 0.9)],
                        trimmed: false
                    ),
                ],
                candidates: [], nonVerse: []
            ),
            cursor: MushafPosition(sura: 1, aya: 5, wordIdx: 1)
        ),
    ]
}
