import Foundation

/// Stories 11 (View Session Summary), 12 (Review Mistakes), 13 (Suggested Revision).
@MainActor
final class TaahudSummaryViewModel: ObservableObject {
    @Published private(set) var summary: SessionSummary
    @Published var selectedMistake: MistakeRecord?

    init(summary: SessionSummary) {
        self.summary = summary
    }

    var mistakesGroupedByChannel: [ErrorChannel: [MistakeRecord]] {
        Dictionary(grouping: summary.mistakes, by: { $0.error.errorType })
    }

    var ayahsToReview: [AyahRevisionSuggestion] { summary.revisionPlan.ayahsToReview }
    var rulesToReview: [RuleRevisionSuggestion] { summary.revisionPlan.rulesToReview }
    var frequentPatterns: [String] { summary.revisionPlan.frequentMistakeDescriptions }

    func select(_ mistake: MistakeRecord) { selectedMistake = mistake }
    func clearSelection() { selectedMistake = nil }
}
