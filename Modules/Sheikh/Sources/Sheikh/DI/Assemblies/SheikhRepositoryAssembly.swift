//
//  SheikhRepositoryAssembly.swift
//  Sheikh
//

import Swinject
import NetworkKit
import RealtimeKit

public final class SheikhRepositoryAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any SheikhRepositoryProtocol).self) { r in
            let net = r.resolve((any NetworkServiceProtocol).self) ?? NetworkService.shared
            let remoteDS = r.resolve((any InstantMeetingsRemoteDataSourceProtocol).self) ?? InstantMeetingsRemoteDataSource(networkService: net)
            let realtimeDS = r.resolve((any InstantMeetingsRealtimeDataSourceProtocol).self) ?? InstantMeetingsRealtimeDataSource(realtimeClient: r.resolve((any RealtimeConnecting).self) ?? RealtimeClient())
            return SheikhRepositoryImpl(
                networkService: net,
                remoteDataSource: remoteDS,
                realtimeDataSource: realtimeDS
            )
        }.inObjectScope(.container)
    }
}
