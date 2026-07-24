//
//  GetMushafPageUseCase.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//




import Foundation

public protocol GetMushafPageUseCase {
    func execute(pageNumber: Int) throws -> MushafPage
}


public final class GetMushafPageUseCaseImpl: GetMushafPageUseCase {
    private let repository: MushafRepository

    public init(repository: MushafRepository) {
        self.repository = repository
    }

    public func execute(pageNumber: Int) throws -> MushafPage {
        try repository.fetchPage(pageNumber)
    }
}
