//
//  ViewModelAssembly.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Swinject

// MARK: - ViewModelAssembly

final class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        // Register PaymentViewModel with a SubscriptionPackage argument.
        // Call: container.resolve(PaymentViewModel.self, argument: somePackage)
        container
            .register(PaymentViewModel.self) { r, package in
                MainActor.assumeIsolated {
                    PaymentViewModel(
                        package: package,
                        useCase: r.resolve(ProcessWalletPaymentUseCase.self)!,
                        cardUseCase: r.resolve(ProcessCardPaymentUseCase.self)!
                    )
                }
            }
            .inObjectScope(.transient)
    }
}
