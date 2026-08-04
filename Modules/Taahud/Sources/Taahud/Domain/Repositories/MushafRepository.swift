//
//  MushafRepository.swift
//  Reading
//
//  Domain layer contract for reading local muṣḥaf layout/glyph data
//  (backed by qpc_v4.db) and the local āyah word index (search-index.db).
//

import Foundation

/// Contract for reading the two local read-only SQLite databases that back
/// the Mushaf UI: page/line/glyph layout, and word-level ayah text.
public protocol MushafRepository {

    /// Loads a full page (line layout + KFGQPC v4 glyphs) by 1-indexed page number.
    func fetchPage(pageNumber: Int) async throws -> MushafPageData

    /// Looks up which page a given (sura, aya, wordIdx) falls on — used to
    /// jump the Mushaf view when the engine's cursor advances past the
    /// currently displayed page, or after a seek.
    func pageNumber(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> Int

    /// Resolves the plain Uthmani text + global word id for a given
    /// (sura, aya, wordIdx) triple, used to pair AI feedback with a specific
    /// on-screen `AyahWord`.
    func word(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> AyahWord?
}
