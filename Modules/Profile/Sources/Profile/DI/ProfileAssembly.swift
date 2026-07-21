//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import Swinject
import SwiftUI
import Settings

public final class ProfileAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        
        container.register(ProfileRouter.self) { _ in
            ProfileRouter()
        }.inObjectScope(.container)
        
        container.register(ProfileCoordinatorView.self) { r in
            let router = r.resolve(ProfileRouter.self)!
            return ProfileCoordinatorView(router: router)
        }
    }
}
