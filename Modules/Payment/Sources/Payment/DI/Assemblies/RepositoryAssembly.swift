//
//  RepositoryAssembly.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Swinject



final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container
            .register(WalletPaymentRepositoryProtocol.self) { r in
                WalletPaymentRepositoryImpl(
                    dataSource: r.resolve(WalletDataSourceProtocol.self)!
                )
            }
            .inObjectScope(.container)
            
        container
            .register(CardPaymentRepositoryProtocol.self) { r in
                CardPaymentRepositoryImpl(
                    dataSource: r.resolve(CardPaymentDataSourceProtocol.self)!
                )
            }
            .inObjectScope(.container)
    }
}
