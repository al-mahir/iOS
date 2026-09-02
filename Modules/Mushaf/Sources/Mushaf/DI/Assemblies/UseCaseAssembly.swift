//
//  UseCaseAssembly.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Swinject

final class UseCaseAssembly: Assembly {
    func assemble(container: Container) {
        container.register(GetMushafPageUseCase.self) { r in
            GetMushafPageUseCaseImpl(repository: r.resolve(MushafRepository.self)!)
        }
    }
}
