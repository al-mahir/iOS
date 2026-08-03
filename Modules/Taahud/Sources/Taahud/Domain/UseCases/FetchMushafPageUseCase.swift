//
//  FetchMushafPageUseCase.swift
//  Reading
//

import Foundation

public protocol FetchMushafPageUseCaseProtocol {
    func execute(pageNumber: Int) async throws -> MushafPageData
}

/// Loads a single muṣḥaf page's layout + glyph data from `qpc_v4.db`.
public final class FetchMushafPageUseCase: FetchMushafPageUseCaseProtocol {
    private let mushafRepository: MushafRepository

    public init(mushafRepository: MushafRepository) {
        self.mushafRepository = mushafRepository
    }

    public func execute(pageNumber: Int) async throws -> MushafPageData {
        try await mushafRepository.fetchPage(pageNumber: pageNumber)
    }
}
