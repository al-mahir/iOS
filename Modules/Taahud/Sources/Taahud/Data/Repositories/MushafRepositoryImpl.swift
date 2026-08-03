//
//  MushafRepositoryImpl.swift
//  Reading
//

import Foundation

final class MushafRepositoryImpl: MushafRepository {
    private let qpcDataSource: QPCV4LocalDataSource
    private let searchIndexDataSource: SearchIndexLocalDataSource

    init(qpcDataSource: QPCV4LocalDataSource, searchIndexDataSource: SearchIndexLocalDataSource) {
        self.qpcDataSource = qpcDataSource
        self.searchIndexDataSource = searchIndexDataSource
    }

    public func fetchPage(pageNumber: Int) async throws -> MushafPageData {
        try qpcDataSource.fetchPage(pageNumber: pageNumber)
    }

    public func pageNumber(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> Int {
        // qpc_v4.db lays pages out by (sura, aya, word_position); the
        // engine's word_idx is 0-based within the ayah, matching word_position.
        try qpcDataSource.pageNumber(forSura: sura, aya: aya, wordPosition: wordIdx)
    }

    public func word(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> AyahWord? {
        guard let row = try? searchIndexDataSource.fetchWord(sura: sura, aya: aya, wordIdx: wordIdx) else {
            return nil
        }
        // search-index.db's global id lines up with qpc_v4.db's word id, so we
        // can build an AyahWord straight from the search-index row; the glyph
        // string is left empty here since only qpc_v4.db carries glyphs — the
        // ViewModel already has the on-page AyahWord (with glyph) from
        // fetchPage(), and only needs this lookup to pair feedback by id.
        return AyahWord(
            id: row.globalWordId,
            sura: row.sura,
            aya: row.aya,
            wordPosition: row.wordIdx,
            text: row.uthmaniText,
            glyphCodePoint: "",
            lineNumber: 0,
            isVerseMarker: false
        )
    }
}
