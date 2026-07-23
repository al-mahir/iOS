import Foundation

/// Story 13: Suggested Revision — ayahs to review, tajwīd rules to review,
/// and which mistakes repeated often enough to call out.
public struct SuggestRevisionUseCase: Sendable {
    public init() {}

    public func execute(mistakes: [MistakeRecord]) -> RevisionPlan {
        // Ayahs: count mistakes per (sura, aya), worst first.
        var ayahCounts: [String: (sura: Int, aya: Int, count: Int)] = [:]
        for m in mistakes {
            let key = "\(m.occurredAt.sura)-\(m.occurredAt.aya)"
            ayahCounts[key, default: (m.occurredAt.sura, m.occurredAt.aya, 0)].count += 1
        }
        let ayahs = ayahCounts.values
            .sorted { $0.count > $1.count }
            .map { AyahRevisionSuggestion(sura: $0.sura, aya: $0.aya, mistakeCount: $0.count) }

        // Rules: count occurrences of each tajwīd rule touched by an error.
        // Fall back to the error channel name when a finding carries no
        // tajweed_rules (e.g. ḥifẓ/tashkīl mistakes have none).
        var ruleCounts: [String: (nameAr: String, count: Int)] = [:]
        for m in mistakes {
            if m.error.tajweedRules.isEmpty {
                let key = m.error.errorType.rawValue
                ruleCounts[key, default: (key, 0)].count += 1
            } else {
                for rule in m.error.tajweedRules {
                    ruleCounts[rule.nameEn, default: (rule.nameAr, 0)].count += 1
                }
            }
        }
        let rules = ruleCounts
            .map { RuleRevisionSuggestion(ruleKeyOrName: $0.key, nameAr: $0.value.nameAr, occurrences: $0.value.count) }
            .sorted { $0.occurrences > $1.occurrences }

        // Frequently repeated mistakes: same expected/predicted phoneme pair
        // recurring 2+ times reads as a pattern worth naming explicitly.
        var pairCounts: [String: Int] = [:]
        for m in mistakes {
            let key = "\(m.error.expectedPh)->\(m.error.predictedPh)"
            pairCounts[key, default: 0] += 1
        }
        let frequent = pairCounts
            .filter { $0.value >= 2 }
            .sorted { $0.value > $1.value }
            .map { "\($0.key) (\($0.value)x)" }

        return RevisionPlan(
            ayahsToReview: Array(ayahs.prefix(10)),
            rulesToReview: Array(rules.prefix(10)),
            frequentMistakeDescriptions: Array(frequent.prefix(10))
        )
    }
}
