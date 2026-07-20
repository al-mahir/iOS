//
//  TabItem.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI


public enum TabItem: Int, CaseIterable, Sendable {
    case home, quran, bookmark, profile
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .quran: return "Quran"
        case .bookmark: return "Bookmark"
        case .profile: return "Profile"
        }
    }
  
    public var iconName: String {
        switch self {
        case .home: return "home"
        case .quran: return "quran"
        case .bookmark: return "bookmark"
        case .profile: return "profile"
        }
    }
    
   
    public var selectedIconName: String {
        switch self {
        case .home: return "home_filled"
        case .quran: return "quran_filled"
        case .bookmark: return "bookmark_filled"
        case .profile: return "profile_filled"
        }
    }
}
