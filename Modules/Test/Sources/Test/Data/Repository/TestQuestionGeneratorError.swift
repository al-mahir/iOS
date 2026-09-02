//
//  TestQuestionGeneratorError.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Foundation

enum TestQuestionGeneratorError: Error {
    /// The requested count is outside the 3...20 bounds, or exceeds how many
    /// distinct starting ayahs the resolved range actually has.
    case invalidCount
}

enum TestQuestionGenerator {
    static let minQuestionCount = 3
    static let maxQuestionCount = 20

    /// The selectable range to show the user for "number of questions",
    /// bounded both by the product rule (3...20) and by how much content is
    /// actually available in their chosen scope. Returns nil if the scope is
    /// too short to support even the minimum of 3 questions.
    static func allowedQuestionCountRange(for resolved: ResolvedTestRange) -> ClosedRange<Int>? {
        let available = resolved.ayahUnits.count
        guard available >= minQuestionCount else { return nil }
        return minQuestionCount...min(maxQuestionCount, available)
    }

    /// Generates `count` non-duplicate questions from the resolved range.
    /// - Parameter randomizeOrder: if false (default), questions are presented
    ///   in ascending Quran order even though their starting ayahs were chosen
    ///   at random; set true to also shuffle presentation order.
    static func generateQuestions(
        count: Int,
        from resolved: ResolvedTestRange,
        randomizeOrder: Bool = false
    ) throws -> [TestQuestion] {
        let units = resolved.ayahUnits
        guard count >= minQuestionCount, count <= maxQuestionCount, count <= units.count else {
            throw TestQuestionGeneratorError.invalidCount
        }

        var indices = Array(units.indices)
        indices.shuffle()
        var chosenStartIndices = Array(indices.prefix(count))
        if !randomizeOrder {
            chosenStartIndices.sort()
        }

        return chosenStartIndices.enumerated().map { position, startIndex in
            let endIndex = endIndex(startingAt: startIndex, in: units)
            let startUnit = units[startIndex]
            let endUnit = units[endIndex]
            return TestQuestion(
                index: position + 1,
                startWordId: startUnit.firstWordId,
                endWordId: endUnit.lastWordId,
                surah: startUnit.surah,
                startAyah: startUnit.ayah,
                endAyah: endUnit.ayah
            )
        }
    }

    /// Extends forward from `i`, stopping when any of the three limits hits:
    /// 3 ayahs total, end of Surah, or end of the resolved range.
    private static func endIndex(startingAt i: Int, in units: [AyahUnit]) -> Int {
        let surah = units[i].surah
        var end = i
        while end + 1 < units.count,       // not at end of range
              (end - i) < 2,               // fewer than 3 ayahs so far
              units[end + 1].surah == surah { // next ayah is still same Surah
            end += 1
        }
        return end
    }
}
