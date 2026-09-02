//
//  HomeRepositoryAssembly.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//



import Swinject

import Swinject
import NetworkKit

public final class HomeRepositoryAssembly: Assembly {
    public init() {}
    public func assemble(container: Container) {
        
        container.register(HomeRemoteDataSourceProtocol.self) { _ in
            HomeRemoteDataSource(networkService: NetworkService.shared)
        }
        container.register(HomeLocalDataSourceProtocol.self) { _ in HomeLocalDataSource() }
        
        container.register(HomeRepositoryProtocol.self) { r in
            HomeRepository(
                remoteDataSource: r.resolve(HomeRemoteDataSourceProtocol.self)!,
                localDataSource: r.resolve(HomeLocalDataSourceProtocol.self)!
            )
        }.inObjectScope(.container)
    }
}
