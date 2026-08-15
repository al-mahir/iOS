//
//  FetchMushafPageUseCase.swift
//  Taahud
//

import Foundation

public protocol FetchMushafPageUseCaseProtocol {
    func execute(pageNumber: Int) async throws -> MushafPageData
}

public final class FetchMushafPageUseCase: FetchMushafPageUseCaseProtocol {
    private let mushafRepository: MushafRepository

    public init(mushafRepository: MushafRepository) {
        self.mushafRepository = mushafRepository
    }

    public func execute(pageNumber: Int) async throws -> MushafPageData {
        try await mushafRepository.fetchPage(pageNumber: pageNumber)
    }
}
