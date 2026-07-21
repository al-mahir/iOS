//
//  TabBarVisibility.swift
//  Common
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import SwiftUI

public final class TabBarVisibility: ObservableObject {
    @Published public var isVisible: Bool = true
    public init() {}
}

private struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue = TabBarVisibility()
}

public extension EnvironmentValues {
    var tabBarVisibility: TabBarVisibility {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}
