//
//  File.swift
//  
//
//  Created by Esraa Ehab on 21/07/2026.
//

import SwiftUI

public final class ProfileRouter: ObservableObject {
    @Published public var path = NavigationPath()
    
    public init() {}
    
    public func push(_ route: ProfileRoute) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }
}
