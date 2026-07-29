//
//  SheikhDIContainer.swift
//  Sheikh
//

import Foundation
import Swinject

public final class SheikhDIContainer: ObservableObject, @unchecked Sendable {

    public static let shared = SheikhDIContainer()

    public let container: Container
    private let assembler: Assembler

    public init() {
        let container = Container()
        self.container = container
        self.assembler = Assembler(
            [
                SheikhDataSourceAssembly(),
                SheikhRepositoryAssembly(),
                SheikhUseCaseAssembly(),
                SheikhViewModelAssembly(),
            ],
            container: container
        )
    }

    @MainActor
    public func makeSheikhListViewModel() -> SheikhListViewModel {
        if let resolved = container.resolve(SheikhListViewModel.self) {
            return resolved
        }
        let useCase = container.resolve((any GetSheikhsUseCaseProtocol).self)!
        return SheikhListViewModel(getSheikhsUseCase: useCase)
    }

    @MainActor
    public func makeSheikhDetailViewModel(sheikhID: String, prefetched: Sheikh? = nil) -> SheikhDetailViewModel {
        if let resolved = container.resolve(SheikhDetailViewModel.self, arguments: sheikhID, prefetched) {
            return resolved
        }
        let getDetailUseCase = container.resolve((any GetSheikhDetailUseCaseProtocol).self)!
        let toggleFavUseCase = container.resolve((any ToggleFavoriteSheikhUseCaseProtocol).self)!
        return SheikhDetailViewModel(
            sheikhID: sheikhID,
            prefetched: prefetched,
            getSheikhDetailUseCase: getDetailUseCase,
            toggleFavoriteUseCase: toggleFavUseCase
        )
    }
}
