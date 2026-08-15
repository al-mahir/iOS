//
//  DIContainer.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import Swinject
import Common

public final class DIContainer {
    @MainActor public static let shared = DIContainer()

    private let container: Container

    private init() {
        let container = Container()

        container.register(Resolver.self) { r in r }

        _ = Assembler(
            [
                DatabaseAssembly(),
                ReadingAssembly(),
                TestAssembly()
            ],
            container: container
        )
        self.container = container
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("DI: could not resolve \(type). Is it registered in an Assembly?")
        }
        return resolved
    }
}
