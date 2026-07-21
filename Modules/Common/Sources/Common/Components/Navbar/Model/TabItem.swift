//
//  TabItem.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI


public enum TabItem: Int, CaseIterable, Sendable {
    case home, bookmark, profile
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .bookmark: return "Bookmark"
        case .profile: return "Profile"
        }
    }
  
    public var iconName: String {
        switch self {
        case .home: return "home"
        case .bookmark: return "bookmark"
        case .profile: return "profile"
        }
    }
    
   
    public var selectedIconName: String {
        switch self {
        case .home: return "home-filled"
        case .bookmark: return "bookmark-filled"
        case .profile: return "profile-filled"
        }
    }
}
