//
//  SearchAyahsUseCase.swift
//  Mushaf
//

import Foundation

@preconcurrency protocol SearchAyahsUseCase {
    func execute(query: String) throws -> [SearchResult]
}

final class SearchAyahsUseCaseImpl: SearchAyahsUseCase {
    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute(query: String) throws -> [SearchResult] {
        try repository.searchAyahs(query: query)
    }
}
