//
//  DIContainer.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//




import Swinject

public final class DIContainer {
    public static let shared = DIContainer()

    public let container: Container
    private let assembler: Assembler

    private init() {
        container = Container()
        assembler = Assembler([
            HomeRepositoryAssembly(),
            HomeUseCaseAssembly(),
            HomeViewModelAssembly()
        ], container: container)
    }

    public func resolve<T>(_ serviceType: T.Type) -> T {
        guard let resolved = container.resolve(serviceType) else {
            fatalError("Failed to resolve dependency for type: \(serviceType)")
        }
        return resolved
    }
}
