//
//  SheikhUseCaseAssembly.swift
//  Sheikh
//

import Swinject

public final class SheikhUseCaseAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any GetSheikhsUseCaseProtocol).self) { r in
            GetSheikhsUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any GetSheikhDetailUseCaseProtocol).self) { r in
            GetSheikhDetailUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any ToggleFavoriteSheikhUseCaseProtocol).self) { r in
            ToggleFavoriteSheikhUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)
    }
}
