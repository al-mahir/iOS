////
////  DIContainer.swift
////  Reading
////
////  Created by Alaa Ayman on 17/07/2026.
////
//
//
//
//import Swinject
//
//@MainActor
//final class DIContainer {
//    static let shared = DIContainer()
//
//    private let container: Container
//
//    private init() {
//        let container = Container()
//        _ = Assembler(
//            [
//                ReadingDIContainer()
//            ],
//            container: container
//        )
//        self.container = container
//    }
//
//    func resolve<T>(_ type: T.Type) -> T {
//        guard let resolved = container.resolve(type) else {
//            fatalError("DI: could not resolve \(type). Is it registered in an Assembly?")
//        }
//        return resolved
//    }
//    
//    func resolveOptional<T>(_ type: T.Type) -> T? {
//        return container.resolve(type)
//    }
//}
