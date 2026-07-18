//
//  MushafRepositoryImpl.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Foundation


final class MushafRepositoryImpl: MushafRepository {
    private let localDataSource: MushafLocalDataSource

  
    private var cache: [Int: MushafPage] = [:]

    init(localDataSource: MushafLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchPage(_ pageNumber: Int) throws -> MushafPage {
        if let cached = cache[pageNumber] {
            return cached
        }

        let layoutRows = try localDataSource.layoutLines(forPage: pageNumber)

        var lines: [MushafLine] = []
        for row in layoutRows {
            let lineType = MushafLineType(rawValue: row.lineType) ?? .ayah

            var words: [QuranWord] = []
            if lineType == .ayah, let firstID = row.firstWordId, let lastID = row.lastWordId {
                let wordRows = try localDataSource.words(fromId: firstID, toId: lastID)
                words = wordRows.map { $0.toDomainEntity() }
            }

            lines.append(row.toDomainEntity(words: words))
        }

        let page = MushafPage(id: pageNumber, lines: lines)
        cache[pageNumber] = page
        return page
    }
}
