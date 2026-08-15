//
//  MushafRepositoryImpl.swift
//  Taahud
//

import Foundation

public final class MushafRepositoryImpl: MushafRepository {
    private let qpcDataSource: QPCV4LocalDataSource
    private let searchIndexDataSource: SearchIndexLocalDataSource

    public init(qpcDataSource: QPCV4LocalDataSource, searchIndexDataSource: SearchIndexLocalDataSource) {
        self.qpcDataSource = qpcDataSource
        self.searchIndexDataSource = searchIndexDataSource
    }

    public func fetchPage(pageNumber: Int) async throws -> MushafPageData {
        try qpcDataSource.fetchPage(pageNumber: pageNumber)
    }

    public func pageNumber(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> Int {
        try qpcDataSource.pageNumber(forSura: sura, aya: aya, wordPosition: wordIdx)
    }

    public func word(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> AyahWord? {
        guard let row = try? searchIndexDataSource.fetchWord(sura: sura, aya: aya, wordIdx: wordIdx) else {
            return nil
        }
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
