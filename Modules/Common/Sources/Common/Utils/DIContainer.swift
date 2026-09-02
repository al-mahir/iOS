//
//  DIContainer.swift
//  Common
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//




import Foundation

public final class DIContainer {
    public static let shared = DIContainer()
    private init() {}

    private var factories: [ObjectIdentifier: () -> Any] = [:]

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    public func resolve<T>(_ type: T.Type) -> T {
        guard let factory = factories[ObjectIdentifier(type)], let value = factory() as? T else {
            fatalError("No registration found for \(type). Did you forget to construct its DependencyContainer at app launch?")
        }
        return value
    }
}
