//
//  SeekRecitationUseCase.swift
//  Taahud
//

import Foundation

public protocol SeekRecitationUseCaseProtocol {
    func execute(sura: Int, aya: Int, wordIdx: Int) async throws -> Int
}

public final class SeekRecitationUseCase: SeekRecitationUseCaseProtocol {
    private let recitationRepository: RecitationRepository
    private let mushafRepository: MushafRepository

    public init(recitationRepository: RecitationRepository, mushafRepository: MushafRepository) {
        self.recitationRepository = recitationRepository
        self.mushafRepository = mushafRepository
    }

    public func execute(sura: Int, aya: Int, wordIdx: Int) async throws -> Int {
        try await recitationRepository.seek(sura: sura, aya: aya, wordIdx: wordIdx)
        return try await mushafRepository.pageNumber(forSura: sura, aya: aya, wordIdx: wordIdx)
    }
}
