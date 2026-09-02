//
//  ListeningDIContainer.swift
//  Listening
//

import Foundation
import Swinject

/// Self-contained DI container for the Listening module.
/// Keeps all Listening dependencies isolated from other modules.
@MainActor
public final class ListeningDIContainer {

    public static let shared = ListeningDIContainer()

    private let container: Container

    private init() {
        let container = Container()
        _ = Assembler([ListeningAssembly()], container: container)
        self.container = container
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("ListeningDI: could not resolve \(type). Is it registered in ListeningAssembly?")
        }
        return resolved
    }
}
