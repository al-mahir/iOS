//
//  PaymentDIContainer.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Swinject

@MainActor
public final class PaymentDIContainer {

    // MARK: Shared instance
    // TODO: Set useMock: false once backend packages table is seeded
    public static let shared = PaymentDIContainer(useMock: true)

    // MARK: Private container

    private let container: Container

    // MARK: Init

    /// Creates a payment DI container.
    /// - Parameter useMock: Set to `true` to use simulated mock data source, default is `false` (real backend API).
    public init(useMock: Bool = false) {
        let container = Container()
        _ = Assembler(
            [
                DataSourceAssembly(useMock: useMock),
                RepositoryAssembly(),
                UseCaseAssembly(),
                ViewModelAssembly()
            ],
            container: container
        )
        self.container = container
    }

    // MARK: Generic resolve

    public func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("PaymentDI: could not resolve \(type). Is it registered in an Assembly?")
        }
        return resolved
    }

    // MARK: Convenience — ViewModel factory

    /// Resolves a `PaymentViewModel` with the given subscription package injected.
    public func resolveViewModel(for package: SubscriptionPackage) -> PaymentViewModel {
        guard let vm = container.resolve(PaymentViewModel.self, argument: package) else {
            fatalError("PaymentDI: could not resolve PaymentViewModel.")
        }
        return vm
    }

    /// Convenience: build the full `PaymentView` in one call.
    public func makePaymentView(for package: SubscriptionPackage) -> PaymentView {
        PaymentView(viewModel: resolveViewModel(for: package))
    }
}
