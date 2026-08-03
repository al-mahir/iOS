//
//  PaymentDIContainer.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Swinject


@MainActor
public final class PaymentDIContainer {

    // MARK: Shared instance (uses MockPaymentDataSource)

    public static let shared = PaymentDIContainer()

    // MARK: Private container

    private let container: Container

    // MARK: Init

    /// Creates a container.
    /// - Parameter configuration: Pass a `PaymobConfiguration` for live API.
    ///   Omit (or pass `nil`) to use the mock data source.
    public init(configuration: PaymobConfiguration? = nil) {
        let container = Container()
        _ = Assembler(
            [
                DataSourceAssembly(configuration: configuration),
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
