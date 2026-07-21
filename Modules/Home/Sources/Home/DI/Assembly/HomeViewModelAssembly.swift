//
//  HomeViewModelAssembly.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//




import Swinject

public final class HomeViewModelAssembly: Assembly {
    public init() {}
    public func assemble(container: Container) {
        container.register(HomeViewModel.self) { r in
            HomeViewModel(
                getGreetingUseCase: r.resolve(GetGreetingUseCaseProtocol.self)!,
                getLastReadUseCase: r.resolve(GetLastReadUseCaseProtocol.self)!,
                getSheikhsUseCase: r.resolve(GetSheikhsUseCaseProtocol.self)!,
                getActiveCirclesUseCase: r.resolve(GetActiveCirclesUseCaseProtocol.self)!,
                getAyahOfTheDayUseCase: r.resolve(GetAyahOfTheDayUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)
    }
}
