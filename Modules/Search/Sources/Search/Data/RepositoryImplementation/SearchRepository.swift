//
//  SearchRepository.swift
//  Mushaf
//

import Foundation

protocol SearchRepository {
    func searchAyahs(query: String) throws -> [SearchResult]
}

final class SearchRepositoryImpl: SearchRepository {
    private let localDataSource: MushafSearchLocalDataSource

    init(localDataSource: MushafSearchLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func searchAyahs(query: String) throws -> [SearchResult] {
        try localDataSource.searchAyahs(query: query)
    }
}
