//
//  GetMushafPageUseCase.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//




import Foundation

protocol GetMushafPageUseCase {
    func execute(pageNumber: Int) throws -> MushafPage
}


final class GetMushafPageUseCaseImpl: GetMushafPageUseCase {
    private let repository: MushafRepository

    init(repository: MushafRepository) {
        self.repository = repository
    }

    func execute(pageNumber: Int) throws -> MushafPage {
        try repository.fetchPage(pageNumber)
    }
}
