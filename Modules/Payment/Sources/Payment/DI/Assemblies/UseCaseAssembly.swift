//
//  UseCaseAssembly.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Swinject


final class UseCaseAssembly: Assembly {
    func assemble(container: Container) {
        container
            .register(ProcessWalletPaymentUseCase.self) { r in
                ProcessWalletPaymentUseCaseImpl(
                    repository: r.resolve(WalletPaymentRepositoryProtocol.self)!
                )
            }
            .inObjectScope(.transient)
            
        container
            .register(ProcessCardPaymentUseCase.self) { r in
                ProcessCardPaymentUseCaseImpl(
                    repository: r.resolve(CardPaymentRepositoryProtocol.self)!
                )
            }
            .inObjectScope(.transient)
    }
}
