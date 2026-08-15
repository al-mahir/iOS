//
//  TabItem.swift
//  Common
//

import SwiftUI

public enum TabItem: Int, CaseIterable, Sendable {
    case home, bookmark, profile

    public var title: LocalizedStringResource {
        switch self {
        case .home:
            return LocalizedStringResource("Home", bundle: .atURL(CommonBundle.bundle.bundleURL))
        case .bookmark:
            return LocalizedStringResource("Bookmarks", bundle: .atURL(CommonBundle.bundle.bundleURL))
        case .profile:
            return LocalizedStringResource("Profile", bundle: .atURL(CommonBundle.bundle.bundleURL))
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
