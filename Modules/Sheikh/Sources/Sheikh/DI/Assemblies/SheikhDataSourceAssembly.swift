//
//  SheikhDataSourceAssembly.swift
//  Sheikh
//

import Swinject
import NetworkKit
import RealtimeKit

public final class SheikhDataSourceAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any NetworkServiceProtocol).self) { _ in
            NetworkService.shared
        }.inObjectScope(.container)

        container.register((any RealtimeConnecting).self) { _ in
            RealtimeClient()
        }.inObjectScope(.container)

        container.register((any InstantMeetingsRemoteDataSourceProtocol).self) { r in
            let net = r.resolve((any NetworkServiceProtocol).self) ?? NetworkService.shared
            return InstantMeetingsRemoteDataSource(networkService: net)
        }.inObjectScope(.container)

        container.register((any InstantMeetingsRealtimeDataSourceProtocol).self) { r in
            let client = r.resolve((any RealtimeConnecting).self) ?? RealtimeClient()
            return InstantMeetingsRealtimeDataSource(realtimeClient: client)
        }.inObjectScope(.container)
    }
}
