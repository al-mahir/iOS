//
//  AppDIContainer.swift
//  AlMahir
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Swinject
import Profile 

final class AppDIContainer {
    static let shared = AppDIContainer()
    
    let container: Container
    private let assembler: Assembler
    
    private init() {
        container = Container()
        assembler = Assembler([
            ProfileAssembly()
        ], container: container)
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(T.self)
    }
}
