//
//  SheikhRepositoryAssembly.swift
//  Sheikh
//

import Swinject
import NetworkKit

public final class SheikhRepositoryAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any SheikhRepositoryProtocol).self) { r in
            let net = r.resolve((any NetworkServiceProtocol).self) ?? NetworkService.shared
            return SheikhRepositoryImpl(networkService: net)
        }.inObjectScope(.container)
    }
}
