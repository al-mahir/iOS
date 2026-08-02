//
//  HomeUseCaseAssembly.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//




import Swinject
import Sheikh
import NetworkKit

public final class HomeUseCaseAssembly: Assembly {
    public init() {}
    public func assemble(container: Container) {
        container.register(GetGreetingUseCaseProtocol.self) { r in GetGreetingUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetLastReadUseCaseProtocol.self) { r in GetLastReadUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetSheikhsUseCaseProtocol.self) { r in
            let sheikhRepo: any SheikhRepositoryProtocol = SheikhRepositoryImpl()
            return GetSheikhsUseCase(repo: sheikhRepo)
        }
        container.register(GetActiveCirclesUseCaseProtocol.self) { r in GetActiveCirclesUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
        container.register(GetAyahOfTheDayUseCaseProtocol.self) { r in GetAyahOfTheDayUseCase(repo: r.resolve(HomeRepositoryProtocol.self)!) }
    }
}
