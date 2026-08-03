//
//  TestRangeError.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//


import Foundation

enum TestRangeError: Error {
    case invalidScope
    case dataNotFound
    case notEnoughContent
}

final class TestRangeResolver {
    private let wordsDAO: WordsDAO
    private let structure: QuranStructureProviding

    init(wordsDAO: WordsDAO, structure: QuranStructureProviding = StaticQuranStructure()) {
        self.wordsDAO = wordsDAO
        self.structure = structure
    }

    func resolve(_ scope: TestScope) throws -> ResolvedTestRange {
        switch scope {
        case .surahRange(let from, let to):
            return try resolveSurahRange(scope: scope, from: from, to: to)
        case .ayahRange(let surah, let fromAyah, let toAyah):
            return try resolveAyahRange(scope: scope, surah: surah, fromAyah: fromAyah, toAyah: toAyah)
        case .juz(let number):
            return try resolveJuz(scope: scope, number: number)
        }
    }

    // MARK: - Surah range

    private func resolveSurahRange(scope: TestScope, from: Int, to: Int) throws -> ResolvedTestRange {
        guard from >= 1, to <= 114, from <= to else { throw TestRangeError.invalidScope }
        guard let firstRange = try wordsDAO.wordIdRange(surah: from) else { throw TestRangeError.dataNotFound }
        guard let lastRange = try wordsDAO.wordIdRange(surah: to) else { throw TestRangeError.dataNotFound }
        return try buildResolvedRange(scope: scope, fromWordId: firstRange.first, toWordId: lastRange.last)
    }

    // MARK: - Ayah range (single Surah)

    private func resolveAyahRange(scope: TestScope, surah: Int, fromAyah: Int, toAyah: Int) throws -> ResolvedTestRange {
        guard fromAyah >= 1, fromAyah <= toAyah else { throw TestRangeError.invalidScope }
        guard let range = try wordsDAO.wordIdRange(surah: surah, fromAyah: fromAyah, toAyah: toAyah) else {
            throw TestRangeError.dataNotFound
        }
        return try buildResolvedRange(scope: scope, fromWordId: range.first, toWordId: range.last)
    }

    // MARK: - Juz'

    private func resolveJuz(scope: TestScope, number: Int) throws -> ResolvedTestRange {
        guard number >= 1, number <= 30 else { throw TestRangeError.invalidScope }
        guard let start = structure.juzStart(number) else { throw TestRangeError.dataNotFound }
        guard let startWordRange = try wordsDAO.wordIdRange(surah: start.surah, fromAyah: start.ayah, toAyah: start.ayah) else {
            throw TestRangeError.dataNotFound
        }
        let startWordId = startWordRange.first

        let endWordId: Int
        if number == 30 {
            guard let lastSurah = try wordsDAO.wordIdRange(surah: 114) else { throw TestRangeError.dataNotFound }
            endWordId = lastSurah.last
        } else {
            guard let next = structure.juzStart(number + 1) else { throw TestRangeError.dataNotFound }
            guard let nextStartWordRange = try wordsDAO.wordIdRange(surah: next.surah, fromAyah: next.ayah, toAyah: next.ayah) else {
                throw TestRangeError.dataNotFound
            }
            endWordId = nextStartWordRange.first - 1
        }

        return try buildResolvedRange(scope: scope, fromWordId: startWordId, toWordId: endWordId)
    }

    // MARK: - Shared

    private func buildResolvedRange(scope: TestScope, fromWordId: Int, toWordId: Int) throws -> ResolvedTestRange {
        guard fromWordId <= toWordId else { throw TestRangeError.notEnoughContent }
        let units = try wordsDAO.ayahBoundaries(fromWordId: fromWordId, toWordId: toWordId)
            .map { AyahUnit(surah: $0.surah, ayah: $0.ayah, firstWordId: $0.firstWordId, lastWordId: $0.lastWordId) }
        guard !units.isEmpty else { throw TestRangeError.notEnoughContent }
        return ResolvedTestRange(scope: scope, ayahUnits: units)
    }
}
