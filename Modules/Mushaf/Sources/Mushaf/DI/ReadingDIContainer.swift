//
//  ReadingDIContainer.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 24/07/2026.
//


import Swinject

@MainActor
final class ReadingDIContainer {
    static let shared = ReadingDIContainer()

    private let container: Container

    private init() {
        let container = Container()
        _ = Assembler(
            [
                ReadingAssembly()
            ],
            container: container
        )
        self.container = container
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("ReadingDI: could not resolve \(type). Is it registered in ReadingAssembly?")
        }
        return resolved
    }
}
