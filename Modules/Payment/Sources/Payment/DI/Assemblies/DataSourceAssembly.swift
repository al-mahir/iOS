//
//  DataSourceAssembly.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Swinject

final class DataSourceAssembly: Assembly {

    private let useMock: Bool

    init(useMock: Bool = false) {
        self.useMock = useMock
    }

    func assemble(container: Container) {
        container
            .register(WalletDataSourceProtocol.self) { [useMock] _ in
                if useMock {
                    return MockWalletDataSource()
                } else {
                    return RemoteWalletPaymentDataSource()
                }
            }
            .inObjectScope(.container)

        container
            .register(CardPaymentDataSourceProtocol.self) { [useMock] _ in
                if useMock {
                    return MockCardPaymentDataSource()
                } else {
                    return RemoteCardPaymentDataSource()
                }
            }
            .inObjectScope(.container)
    }
}
