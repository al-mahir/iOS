//
//  HomeUseCaseAssembly.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//




import Swinject

public final class HomeUseCaseAssembly: Assembly {
    public init() {}
    public func assemble(container: Container) {
        container.register(GetGreetingUseCaseProtocol.self) { r in GetGreetingUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetLastReadUseCaseProtocol.self) { r in GetLastReadUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetSheikhsUseCaseProtocol.self) { r in GetSheikhsUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetActiveCirclesUseCaseProtocol.self) { r in GetActiveCirclesUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetAyahOfTheDayUseCaseProtocol.self) { r in GetAyahOfTheDayUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
    }
}
