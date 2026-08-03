//
//  DataSourceAssembly.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Swinject



final class DataSourceAssembly: Assembly {

    private let configuration: PaymobConfiguration?

    init(configuration: PaymobConfiguration? = nil) {
        self.configuration = configuration
    }

    func assemble(container: Container) {
        container
            .register(WalletDataSourceProtocol.self) { [configuration] _ in
                if let config = configuration {
           
                    return RemoteWalletPaymentDataSource(config: config)
                } else {
                
                    return MockWalletDataSource()
                }
            }
            .inObjectScope(.container)

        container
            .register(CardPaymentDataSourceProtocol.self) { [configuration] _ in
                if let config = configuration {
     
                    return RemoteCardPaymentDataSource(config: config)
                } else {
            
                    return MockCardPaymentDataSource()
                }
            }
            .inObjectScope(.container)
    }
}
