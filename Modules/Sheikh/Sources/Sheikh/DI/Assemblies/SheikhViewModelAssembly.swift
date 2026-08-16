//
//  SheikhViewModelAssembly.swift
//  Sheikh
//

import Swinject

public final class SheikhViewModelAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register(SheikhListViewModel.self) { r in
            MainActor.assumeIsolated {
                SheikhListViewModel(
                    getSheikhsUseCase: r.resolve((any GetSheikhsUseCaseProtocol).self)!,
                    toggleFavoriteUseCase: r.resolve((any ToggleFavoriteSheikhUseCaseProtocol).self)!
                )
            }
        }.inObjectScope(.transient)

        container.register(SheikhDetailViewModel.self) { (r: Resolver, sheikhID: String, prefetched: Sheikh?) in
            MainActor.assumeIsolated {
                SheikhDetailViewModel(
                    sheikhID: sheikhID,
                    prefetched: prefetched,
                    getSheikhDetailUseCase: r.resolve((any GetSheikhDetailUseCaseProtocol).self)!,
                    toggleFavoriteUseCase: r.resolve((any ToggleFavoriteSheikhUseCaseProtocol).self)!
                )
            }
        }.inObjectScope(.transient)
    }
}
