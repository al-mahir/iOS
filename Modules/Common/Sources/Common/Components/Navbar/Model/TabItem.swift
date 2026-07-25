//
//  TabItem.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI


public enum TabItem: Int, CaseIterable, Sendable {
    case home, profile
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .profile: return "Profile"
        }
    }
  
    public var iconName: String {
        switch self {
        case .home: return "home"
        case .profile: return "profile"
        }
    }
    
   
    public var selectedIconName: String {
        switch self {
        case .home: return "home-filled"
        case .profile: return "profile-filled"
        }
    }
}
