//
//  SheikhDataSourceAssembly.swift
//  Sheikh
//

import Swinject
import NetworkKit

public final class SheikhDataSourceAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any NetworkServiceProtocol).self) { _ in
            NetworkService.shared
        }.inObjectScope(.container)
    }
}
