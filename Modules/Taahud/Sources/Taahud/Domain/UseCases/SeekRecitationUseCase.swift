//
//  SeekRecitationUseCase.swift
//  Reading
//

import Foundation

public protocol SeekRecitationUseCaseProtocol {
    /// Sends a `seek` to the engine, then resolves and returns the page the
    /// new cursor lands on so the ViewModel can flip the Mushaf view if needed.
    func execute(sura: Int, aya: Int, wordIdx: Int) async throws -> Int
}

/// Handles user-initiated jumps: tapping an ayah directly, or turning a page
/// that isn't simply "the next one" the engine would have reached on its own.
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
