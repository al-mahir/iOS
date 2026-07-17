//
//  RepositoryAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Swinject
import Foundation

final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MushafRepository.self) { r in
            guard let localDataSource = r.resolve(MushafLocalDataSource?.self) ?? nil else {
             
                return UnavailableMushafRepository()
            }
            return MushafRepositoryImpl(localDataSource: localDataSource)
        }.inObjectScope(.container)
    }
}

private struct UnavailableMushafRepository: MushafRepository {
    struct UnavailableError: LocalizedError {
        var errorDescription: String? {
            "Mushaf databases could not be opened. Check that qpc-v4.db and qpc-v4-tajweed-15-lines.db are added to the app target."
        }
    }

    func fetchPage(_ pageNumber: Int) throws -> MushafPage {
        throw UnavailableError()
    }
}
